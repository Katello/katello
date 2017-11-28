require 'set'

module Katello
  module Concerns::PulpDatabaseUnit
    extend ActiveSupport::Concern

    #  Class.repository_association_class
    #  Class#update_from_json

    def backend_data
      self.class.pulp_data(uuid) || {}
    end

    module ClassMethods
      def content_unit_class
        "::Katello::Pulp::#{self.name.demodulize}".constantize
      end

      def manage_repository_association
        true
      end

      def repository_association
        repository_association_class.name.demodulize.pluralize.underscore
      end

      def immutable_unit_types
        [Katello::Rpm, Katello::Srpm]
      end

      def with_identifiers(ids)
        ids = [ids] unless ids.is_a?(Array)
        ids.map!(&:to_s)
        id_integers = ids.map { |string| Integer(string) rescue -1 }
        where("#{self.table_name}.id in (?) or #{self.table_name}.uuid in (?)", id_integers, ids)
      end

      def in_repositories(repos)
        where(:id => repository_association_class.where(:repository_id => repos).select(unit_id_field))
      end

      def pulp_data(uuid)
        content_unit_class.new(uuid)
      end

      # Import all units of a single type and refresh their repository associations
      def import_all(uuids = nil, options = {})
        index_repository_association = options.fetch(:index_repository_association, true) && self.manage_repository_association

        process_block = lambda do |units|
          units.each do |unit|
            unit = unit.with_indifferent_access
            item = Katello::Util::Support.active_record_retry do
              self.where(:uuid => unit['_id']).first_or_create
            end
            item.update_from_json(unit)
          end
          if index_repository_association
            units.map { |unit| unit.slice('_id', 'repository_memberships') }
          else
            units.count
          end
        end

        if uuids
          results = content_unit_class.fetch_by_uuids(uuids, &process_block).flatten
          update_repository_associations(results, true) if index_repository_association
        else
          results = content_unit_class.fetch_all(&process_block).flatten
          update_repository_associations(results) if index_repository_association
        end
      end

      def import_for_repository(repository, force = false)
        ids = content_unit_class.ids_for_repository(repository.pulp_id)
        # Rpms cannot change in Pulp so we do not index them if they are already present
        # in our database. Errata and Package Groups can change in Pulp, so we index
        # all of them in the repository on each sync.
        if immutable_unit_types.include?(self) && !force
          ids_to_import = ids - repository.rpms.map(&:uuid)
        else
          ids_to_import = ids
        end
        self.import_all(ids_to_import, :index_repository_association => false) if repository.content_view.default? || force
        self.sync_repository_associations(repository, :uuids => ids) if self.manage_repository_association
      end

      def unit_id_field
        "#{self.name.demodulize.underscore}_id"
      end

      def copy_repository_associations(source_repo, dest_repo)
        delete_query = "delete from #{repository_association_class.table_name} where repository_id = #{dest_repo.id} and
                       #{unit_id_field} not in (select #{unit_id_field} from #{repository_association_class.table_name} where repository_id = #{source_repo.id})"
        ActiveRecord::Base.connection.execute(delete_query)

        insert_query = "insert into #{repository_association_class.table_name} (repository_id, #{unit_id_field})
                        select #{dest_repo.id} as repository_id, #{unit_id_field} from #{repository_association_class.table_name}
                        where repository_id = #{source_repo.id} and #{unit_id_field} not in (select #{unit_id_field}
                        from #{repository_association_class.table_name} where repository_id = #{dest_repo.id})"
        ActiveRecord::Base.connection.execute(insert_query)
      end

      def sync_repository_associations(repository, options = {})
        additive = options.fetch(:additive, false)
        associated_ids = options.fetch(:ids, nil)
        uuids = options.fetch(:uuids) if associated_ids.nil?

        associated_ids = with_uuid(uuids).pluck(:id) if uuids

        table_name = self.repository_association_class.table_name
        attribute_name = unit_id_field

        existing_ids = self.repository_association_class.uncached do
          self.repository_association_class.where(:repository_id => repository).pluck(attribute_name)
        end
        new_ids = associated_ids - existing_ids
        delete_ids = existing_ids - associated_ids

        queries = []

        if delete_ids.any? && !additive
          queries << "DELETE FROM #{table_name} WHERE repository_id=#{repository.id} AND #{attribute_name} IN (#{delete_ids.join(', ')})"
        end

        unless new_ids.empty?
          inserts = new_ids.map { |unit_id| "(#{unit_id.to_i}, #{repository.id.to_i}, '#{Time.now.utc.to_s(:db)}', '#{Time.now.utc.to_s(:db)}')" }
          queries << "INSERT INTO #{table_name} (#{attribute_name}, repository_id, created_at, updated_at) VALUES #{inserts.join(', ')}"
        end

        ActiveRecord::Base.transaction do
          queries.each do |query|
            ActiveRecord::Base.connection.execute(query)
          end
        end
      end

      def with_uuid(unit_uuids)
        where(:uuid => unit_uuids)
      end

      def update_repository_associations(units_json, additive = false)
        ActiveRecord::Base.transaction do
          repo_unit_id = {}
          repo_cache = {}
          units_json.each do |unit_json|
            unit_json['repository_memberships'].each do |repo_pulp_id|
              if (repo_cache[repo_pulp_id] ||= Repository.exists?(:pulp_id => repo_pulp_id))
                repo_unit_id[repo_pulp_id] ||= []
                repo_unit_id[repo_pulp_id] << unit_json['_id']
              end
            end
          end

          repo_unit_id.each do |repo_pulp_id, unit_uuids|
            sync_repository_associations(Repository.find_by(:pulp_id => repo_pulp_id), :uuids => unit_uuids, :additive => additive)
          end
        end
      end
    end
  end
end
