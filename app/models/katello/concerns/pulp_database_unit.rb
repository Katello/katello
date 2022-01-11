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
          facet_repos = facet_repos.merge(hosts).reorder(nil)
          facet_content_units = facet_content_units.merge(hosts).reorder(nil)
        end

        self.joins(repository_association_units).
            where(repository_association_class.table_name => {:repository_id => facet_repos,
                                                              content_unit_association_id => facet_content_units}).distinct
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

      def import_all(pulp_ids = nil, repository = nil, generic_content_type = nil)
        ids_to_associate = []
        if generic_content_type
          service_class = SmartProxy.pulp_primary!.content_service(generic_content_type)
        else
          service_class = SmartProxy.pulp_primary!.content_service(content_type)
        end
        service_class.pulp_units_batch_all(pulp_ids).each do |units|
          units.each do |unit|
            unit = unit.with_indifferent_access
            if content_type == 'rpm' && repository
              rpms_to_disassociate = ::Katello::Rpm.where(name: unit[:name], version: unit[:version], release: unit[:release],
                                                          epoch: unit[:epoch], arch: unit[:arch]).select(:id)
              if rpms_to_disassociate.any?
                ::Katello::RepositoryRpm.where(rpm_id: rpms_to_disassociate, repository_id: repository.id).destroy_all
              end
            end
            model = Katello::Util::Support.active_record_retry do
              self.where(:pulp_id => unit[service_class.unit_identifier]).first_or_create
            end
            service = service_class.new(model.pulp_id)
            service.backend_data = unit
            if repository&.generic?
              service.update_model(model, generic_content_type)
            end
            service.update_model(model)
            ids_to_associate << model.pulp_id
          end
        end
        sync_repository_associations(repository, :pulp_ids => ids_to_associate, :additive => true) if self.many_repository_associations && repository && ids_to_associate.present?
      end

      # rubocop:disable Metrics/MethodLength
      def import_for_repository(repository, generic_content_type: nil, full_index: false)
        pulp_id_href_map = {}
        if generic_content_type
          service_class = SmartProxy.pulp_primary!.content_service(generic_content_type)
        else
          service_class = SmartProxy.pulp_primary!.content_service(content_type)
        end
        fetch_only_ids = !full_index &&
                         !repository.content_view.default? &&
                         !repository.repository_type.unique_content_per_repo &&
                         service_class.supports_id_fetch?

        erratum_updated_ids = []
        service_class.pulp_units_batch_for_repo(repository, fetch_identifiers: fetch_only_ids, content_type: generic_content_type).each do |units|
          units.each do |unit|
            unit = unit.with_indifferent_access
            pulp_id = unit[service_class.unit_identifier]
            backend_identifier = unit.dig(service_class.backend_unit_identifier)
            unless fetch_only_ids
              model = Katello::Util::Support.active_record_retry do
                self.where(:pulp_id => pulp_id).first_or_create
              end
              service = service_class.new(model.pulp_id)
              service.backend_data = unit
              model.repository_id = repository.id unless many_repository_associations

              if repository.generic?
                service.update_model(model, generic_content_type)
              elsif self == ::Katello::Erratum
                # Errata will change pulp_hrefs if the upstream repo updates them
                erratum_updated_ids << service.update_model(model, repository)
              else
                service.update_model(model)
              end
            end
            pulp_id_href_map[pulp_id] = backend_identifier
          end
        end
        sync_repository_associations(repository, :pulp_id_href_map => pulp_id_href_map, generic_content_type: generic_content_type, erratum_updated_ids: erratum_updated_ids.uniq) if self.many_repository_associations
      end

      def sync_repository_associations(repository, options = {})
        additive = options.fetch(:additive, false)
        generic_content_type = options.fetch(:generic_content_type, nil)
        pulp_id_href_map = options.dig(:pulp_id_href_map) || {}
        pulp_ids = options.dig(:pulp_ids) || pulp_id_href_map.try(:keys)
        ids_for_repository = with_pulp_id(pulp_ids).pluck(:id, :pulp_id)
        associated_ids = ids_for_repository.map(&:first)
        id_href_map_for_repository = {}
        ids_for_repository.each { |id_href| id_href_map_for_repository[id_href[0]] = id_href[1] }
        id_href_map_for_repository.each_pair { |k, v| id_href_map_for_repository[k] = pulp_id_href_map[v] }
        erratum_updated_ids = options.fetch(:erratum_updated_ids, []).flatten.compact

        existing_ids = self.repository_association_class.uncached do
          repo_assoc_units = self.repository_association_class.where(:repository_id => repository)

          if generic_content_type
            generic_unit_ids = Katello::GenericContentUnit
              .where(id: repo_assoc_units.pluck(unit_id_field))
              .where(content_type: generic_content_type).pluck(:id)
            repo_assoc_units = repo_assoc_units.where(generic_content_unit_id: generic_unit_ids)
          end

          repo_assoc_units.pluck(unit_id_field)
        end

        new_ids = associated_ids - existing_ids
        ActiveRecord::Base.transaction do
          if !additive && (delete_ids = existing_ids - associated_ids).any?
            query = "DELETE FROM #{self.repository_association_class.table_name} WHERE repository_id=#{repository.id} AND #{unit_id_field} IN (#{delete_ids.join(', ')})"
            ActiveRecord::Base.connection.execute(query)
          end
          if self == ::Katello::Erratum
            self.update_repo_association_records(new_ids, erratum_updated_ids, id_href_map_for_repository, repository)
          else
            unless new_ids.empty?
              self.repository_association_class.import(db_columns_sync, db_values(new_ids, id_href_map_for_repository, repository), validate: false)
            end
          end
        end
      end
      # rubocop:enable Metrics/MethodLength

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

      def with_pulp_id(unit_pulp_ids)
        where('pulp_id in (?)', unit_pulp_ids)
      end

      def db_columns_sync
        [unit_id_field, backend_identifier_field, :repository_id, :created_at, :updated_at].compact
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

      def db_values(new_ids, pulp_id_href_map, repository)
        new_ids.map { |unit_id| [unit_id.to_i, pulp_id_href_map.dig(unit_id), repository.id.to_i, Time.now.utc.to_s(:db), Time.now.utc.to_s(:db)].compact }
      end
    end
  end
end
