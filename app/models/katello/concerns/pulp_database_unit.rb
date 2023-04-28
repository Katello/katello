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

      def backend_identifier_field
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

      def content_unit_association_id
        "#{self.name.demodulize.underscore}_id".to_sym #Rpm => rpm_id
      end

      def repository_association_units
        repository_association_class.name.demodulize.pluralize.underscore.to_sym
      end

      def content_units_name
        self.name.demodulize.pluralize.underscore.to_sym
      end

      def import_for_repository(repo, options = {})
        content_type = options[:content_type] || self.content_type
        Katello::ContentUnitIndexer.new(content_type: Katello::RepositoryTypeManager.find_content_type(content_type), repository: repo).import_all
      end

      def import_all(unit_ids, repository = nil, options = {})
        content_type = options[:content_type] || self.content_type
        filtered_indexing = options[:filtered_indexing] || false
        Katello::ContentUnitIndexer.new(content_type: Katello::RepositoryTypeManager.find_content_type(content_type), repository: repository, pulp_content_ids: unit_ids).import_all(filtered_indexing)
      end

      def copy_repository_associations(source_repo, dest_repo)
        if many_repository_associations
          delete_query = "delete from #{repository_association_class.table_name} where repository_id = #{dest_repo.id} and
                         #{unit_id_field} not in (select #{unit_id_field} from #{repository_association_class.table_name} where repository_id = #{source_repo.id})"
          ActiveRecord::Base.transaction do
            ActiveRecord::Base.connection.execute(delete_query)
            self.repository_association_class.import(db_columns_copy, db_values_copy(source_repo, dest_repo), validate: false)
          end
        else
          columns = column_names - ["id", "pulp_id", "created_at", "updated_at", "repository_id"]
          queries = []
          queries << "delete from #{self.table_name} where repository_id = #{dest_repo.id} and
                          pulp_id not in (select pulp_id from #{self.table_name} where repository_id = #{source_repo.id})"
          queries << "insert into #{self.table_name} (repository_id, pulp_id, #{columns.join(',')})
                    select #{dest_repo.id} as repository_id, pulp_id, #{columns.join(',')} from #{self.table_name}
                    where repository_id = #{source_repo.id} and pulp_id not in (select pulp_id
                    from #{self.table_name} where repository_id = #{dest_repo.id})"
          ActiveRecord::Base.transaction do
            queries.each do |query|
              ActiveRecord::Base.connection.execute(query)
            end
          end
        end
      end

      def db_columns_copy
        [unit_id_field, backend_identifier_field, :repository_id].compact
      end

      def db_values_copy(source_repo, dest_repo)
        db_values = []
        existing_unit_ids = self.repository_association_class.where(repository: dest_repo).pluck(unit_id_field)
        if existing_unit_ids.empty?
          new_units = self.repository_association_class.where(repository: source_repo)
        else
          new_units = self.repository_association_class.where(repository: source_repo).where.not("#{unit_id_field} in (?) ", existing_unit_ids)
        end
        unit_backend_identifier_field = backend_identifier_field
        unit_identifier_filed = unit_id_field
        new_units.each do |unit|
          db_values << [unit[unit_identifier_filed], unit[unit_backend_identifier_field], dest_repo.id].compact
        end
        db_values
      end

      def installable_for_content_facet(facet, env = nil, content_view = nil)
        repos = if env && content_view
                  Katello::Repository.in_environment(env).in_content_views([content_view])
                else
                  facet.bound_repositories.pluck(:id)
                end
        facet.send("applicable_#{content_units_name}".to_sym).in_repositories(repos)
      end

      def installable_for_hosts(hosts = nil)
        # Main goal of this query
        # 1) Get me the applicable content units for these set of hosts
        # 2) Now further prune this list. Only include units from repos that have been "enabled" on those hosts.
        #    In other words, prune the list to only include the units in the "bound" repositories signified by
        #    the inner join between ContentFacetRepository and Repository<Unit>

        facet_repos = Katello::ContentFacetRepository.joins(:content_facet => :host).select(:repository_id)
        facet_content_units = content_facet_association_class.joins(:content_facet => :host).select(content_unit_association_id)

        if hosts
          hosts = ::Host.where(id: hosts) if hosts.is_a?(Array)
          facet_repos = facet_repos.where(hosts: { id: hosts }).reorder(nil)
          facet_content_units = facet_content_units.where(hosts: { id: hosts }).reorder(nil)
        end

        self.joins(repository_association_units).
          where(repository_association_class.table_name => { :repository_id => facet_repos,
                                                             content_unit_association_id => facet_content_units }).distinct
      end

      def with_identifiers(ids)
        ids = [ids] unless ids.is_a?(Array)
        ids.map!(&:to_s)
        id_integers = ids.map { |string| Integer(string) rescue -1 }
        where("#{self.table_name}.id in (?) or #{self.table_name}.pulp_id in (?)", id_integers, ids)
      end

      def orphaned
        if many_repository_associations
          where.not(:id => repository_association_class.where(:repository_id => ::Katello::Repository.all).select(unit_id_field))
        else
          where.not(:repository_id => ::Katello::Repository.all)
        end
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

      def with_pulp_id(unit_pulp_ids)
        where('pulp_id in (?)', unit_pulp_ids)
      end

      def unit_id_field
        "#{self.name.demodulize.underscore}_id"
      end
    end
  end
end
