require 'set'

module Katello
  module Concerns::PulpDatabaseUnit
    extend ActiveSupport::Concern
    #  Class.repository_association_class
    included do
      if many_repository_associations
        # rubocop:disable Rails/ReflectionClassName
        has_many repository_association.to_sym, class_name: repository_association_class_name,
                 dependent: :delete_all, inverse_of: association_name
        has_many :repositories, through: repository_association.to_sym, class_name: "Katello::Repository"
        include ::Katello::Concerns::SearchByRepositoryName
      end
    end

    def backend_data
      self.class.pulp_data(pulp_id) || {}
    end

    def remove_from_repository(repo_id)
      self.class.repository_association_class.where(:repository_id => repo_id, self.class.unit_id_field.to_sym => self.id).delete_all
    end

    def library_repositories
      self.repositories.where(library_instance: nil)
    end

    module ClassMethods
      def association_name
        self.name.demodulize.underscore
      end

      def repository_association_class_name
        "::Katello::Repository#{self.name.demodulize}"
      end

      def repository_association_class
        repository_association_class_name.constantize
      end

      def content_type
        self::CONTENT_TYPE
      end

      def content_unit_class
        "::Katello::Pulp::#{self.name.demodulize}".constantize
      end

      def many_repository_associations
        self != YumMetadataFile
      end

      def repository_association
        repository_association_class_name.demodulize.pluralize.underscore
      end

      def immutable_unit_types
        [Katello::Rpm, Katello::Srpm]
      end

      def with_identifiers(ids)
        ids = [ids] unless ids.is_a?(Array)
        ids.map!(&:to_s)
        id_integers = ids.map { |string| Integer(string) rescue -1 }
        where("#{self.table_name}.id in (?) or #{self.table_name}.pulp_id in (?)", id_integers, ids)
      end

      def in_repositories(repos)
        if many_repository_associations
          where(:id => repository_association_class.where(:repository_id => repos).select(unit_id_field))
        else
          where(:repository_id => repos)
        end
      end

      def pulp_data(pulp_id)
        content_unit_class.new(pulp_id)
      end

      def unit_id_field
        "#{self.name.demodulize.underscore}_id"
      end

      def import_all(pulp_ids = nil, repository = nil)
        ids_to_associate = []
        service_class = SmartProxy.pulp_master!.content_service(content_type)
        service_class.pulp_units_batch_all(pulp_ids).each do |units|
          units.each do |unit|
            unit = unit.with_indifferent_access
            model = Katello::Util::Support.active_record_retry do
              self.where(:pulp_id => unit[service_class.unit_identifier]).first_or_create
            end
            service = service_class.new(model.pulp_id)
            service.backend_data = unit
            service.update_model(model)
            ids_to_associate << model.pulp_id
          end
        end
        sync_repository_associations(repository, :pulp_ids => ids_to_associate, :additive => true) if self.many_repository_associations && repository && ids_to_associate.present?
      end

      def import_for_repository(repository)
        pulp_ids = []
        service_class = SmartProxy.pulp_master!.content_service(content_type)
        fetch_only_ids = !repository.content_view.default? &&
                         !repository.repository_type.unique_content_per_repo

        service_class.pulp_units_batch_for_repo(repository, fetch_identifiers: fetch_only_ids).each do |units|
          units.each do |unit|
            unit = unit.with_indifferent_access
            pulp_id = unit[service_class.unit_identifier]
            unless fetch_only_ids
              model = Katello::Util::Support.active_record_retry do
                self.where(:pulp_id => pulp_id).first_or_create
              end
              service = service_class.new(model.pulp_id)
              service.backend_data = unit
              model.repository_id = repository.id unless many_repository_associations
              service.update_model(model)
            end
            pulp_ids << pulp_id
          end
        end
        sync_repository_associations(repository, :pulp_ids => pulp_ids) if self.many_repository_associations
      end

      def sync_repository_associations(repository, options = {})
        additive = options.fetch(:additive, false)
        pulp_ids = options.fetch(:pulp_ids, nil)
        associated_ids = with_pulp_id(pulp_ids).pluck(:id) if pulp_ids

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

      def copy_repository_associations(source_repo, dest_repo)
        if many_repository_associations
          delete_query = "delete from #{repository_association_class.table_name} where repository_id = #{dest_repo.id} and
                         #{unit_id_field} not in (select #{unit_id_field} from #{repository_association_class.table_name} where repository_id = #{source_repo.id})"

          insert_query = "insert into #{repository_association_class.table_name} (repository_id, #{unit_id_field})
                          select #{dest_repo.id} as repository_id, #{unit_id_field} from #{repository_association_class.table_name}
                          where repository_id = #{source_repo.id} and #{unit_id_field} not in (select #{unit_id_field}
                          from #{repository_association_class.table_name} where repository_id = #{dest_repo.id})"
        else
          columns = column_names - ["id", "pulp_id", "created_at", "updated_at", "repository_id"]

          delete_query = "delete from #{self.table_name} where repository_id = #{dest_repo.id} and
                          pulp_id not in (select pulp_id from #{self.table_name} where repository_id = #{source_repo.id})"
          insert_query = "insert into #{self.table_name} (repository_id, pulp_id, #{columns.join(',')})
                    select #{dest_repo.id} as repository_id, pulp_id, #{columns.join(',')} from #{self.table_name}
                    where repository_id = #{source_repo.id} and pulp_id not in (select pulp_id
                    from #{self.table_name} where repository_id = #{dest_repo.id})"

        end
        ActiveRecord::Base.connection.execute(delete_query)
        ActiveRecord::Base.connection.execute(insert_query)
      end

      def with_pulp_id(unit_pulp_ids)
        where('pulp_id in (?)', unit_pulp_ids)
      end
    end
  end
end
