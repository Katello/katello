module Katello
  class ContentUnitIndexer
    def initialize(content_type:, repository: nil, pulp_content_ids: nil, optimized: true)
      @content_type = content_type
      @model_class = content_type.model_class
      @service_class = SmartProxy.pulp_primary!.content_service(content_type)
      @repository = repository
      @content_type = content_type
      @pulp_content_ids = pulp_content_ids
      @optimized = optimized
    end

    def remove_duplicates(unit)
      #when we are uploading units, we need to remove any duplicates from our indexed data
      if @content_type.label == 'rpm' && @repository && @pulp_content_ids
        rpms_to_disassociate = ::Katello::Rpm.where(name: unit[:name], version: unit[:version], release: unit[:release],
                                                    epoch: unit[:epoch], arch: unit[:arch]).select(:id)
        if rpms_to_disassociate.any?
          ::Katello::RepositoryRpm.where(rpm_id: rpms_to_disassociate, repository_id: @repository.id).destroy_all
        end
      end
    end

    def import_all(filtered_indexing = false)
      association_tracker = RepoAssociationTracker.new(@content_type, @service_class, @repository)
      units_from_pulp.each do |units|
        units.each do |unit|
          association_tracker.push(unit)
          remove_duplicates(unit)
        end

        unless fetch_only_ids
          to_insert = units.map do |unit|
            if @content_type.generic?
              @service_class.generate_model_row(unit, @content_type)
            else
              @service_class.generate_model_row(unit)
            end
          end

          # Even after this bug (https://github.com/pulp/pulp_rpm/issues/2821) is fixed,
          # it is possible to have duplicate errata asosociated to a repo.
          if @content_type.label == 'erratum'
            to_insert.uniq! { |row| row["pulp_id"] || row[:pulp_id] }
          end

          next if to_insert.empty?
          insert_timestamps(to_insert)
          if @content_type.mutable
            @model_class.upsert_all(to_insert, unique_by: :pulp_id)
          else
            @model_class.insert_all(to_insert, unique_by: :pulp_id)
          end
        end

        import_associations(units) if @repository
      end

      if @repository
        sync_repository_associations(association_tracker, additive: filtered_indexing)
      end
    end

    def reimport_units
      units_from_pulp.each do |units|
        to_update = units.map do |unit|
          @service_class.generate_model_row(unit)
        end
        @model_class.upsert_all(to_update, unique_by: :pulp_id)
      end
    end

    def import_associations(units)
      pulp_id_to_id = self.class.pulp_id_to_id_map(@content_type, units.map { |unit| unit[@service_class.unit_identifier] })
      @service_class.insert_child_associations(units, pulp_id_to_id) if @service_class.respond_to?(:insert_child_associations)
    end

    def units_from_pulp(&block)
      if @pulp_content_ids
        @service_class.pulp_units_batch_all(@pulp_content_ids, &block)
      elsif @repository
        @service_class.pulp_units_batch_for_repo(@repository, fetch_identifiers: fetch_only_ids, content_type: @content_type, &block)
      end
    end

    def self.pulp_id_to_id_map(content_type, pulp_ids)
      map = {}
      content_type.model_class.with_pulp_id(pulp_ids).select(:id, :pulp_id).each do |model|
        map[model.pulp_id] = model.id
      end
      map
    end

    class RepoAssociationTracker
      def initialize(content_type, service_class, repository)
        @values = {}
        @content_type = content_type
        @repository = repository
        @service_class = service_class
      end

      def unit_ids
        db_values.map { |row| row[@content_type.model_class.unit_id_field] }
      end

      #pulp_href is only provided if we're storing a different 'pulp_id' on the repo association
      def push(unit)
        if @service_class.backend_unit_identifier
          pulp_href = unit.dig(@service_class.backend_unit_identifier)
        else
          pulp_href = nil
        end
        unit_id = unit[@service_class.unit_identifier]
        @values[unit_id] = pulp_href
      end

      def db_values
        return @final_values if @final_values
        @final_value = []

        @final_values = ::Katello::ContentUnitIndexer.pulp_id_to_id_map(@content_type, @values.keys).map do |pulp_id, katello_id|
          #:repository_id => X, :erratum_id => y
          row = {:repository_id => @repository.id, @content_type.model_class.unit_id_field => katello_id}
          row[pulp_href_association_name] = @values[pulp_id] if pulp_href_association_name
          row
        end
        ContentUnitIndexer.insert_timestamps(@content_type.model_class, @final_values)
        @final_values
      end

      def pulp_href_association_name
        'erratum_pulp3_href' if @content_type.label == 'erratum'
      end
    end

    def insert_timestamps(units)
      self.class.insert_timestamps(@model_class, units)
    end

    def self.insert_timestamps(model_class, units)
      dates = model_class.columns.map(&:name).include?("created_at")
      return units unless dates
      units.each do |row|
        row[:created_at] = DateTime.now
        row[:updated_at] = DateTime.now
      end
      units
    end

    def fetch_only_ids
      @optimized && @repository &&
        !@repository.content_view.default? &&
        !@repository.repository_type.unique_content_per_repo &&
        @service_class.supports_id_fetch?
    end

    def sync_repository_associations(assocication_tracker, additive: false)
      unless additive
        ActiveRecord::Base.connection.uncached do
          repo_associations_to_destroy = @model_class.repository_association_class.where(repository_id: @repository.id).where.
            not(@model_class.unit_id_field => assocication_tracker.unit_ids)
          clean_filter_rules(repo_associations_to_destroy) if repo_associations_to_destroy.present? && [::Katello::ModuleStream, ::Katello::Erratum, ::Katello::PackageGroup].include?(@model_class)
          repo_associations_to_destroy.destroy_all
        end
      end
      return if assocication_tracker.db_values.empty?
      @model_class.repository_association_class.upsert_all(assocication_tracker.db_values, :unique_by => association_class_uniqiness_attributes)
    end

    def clean_filter_rules(repo_associations_to_destroy)
      affected_content_view_ids = @repository.content_views.non_default.pluck(:id)
      return false if affected_content_view_ids.empty?
      case @model_class.to_s
      when 'Katello::ModuleStream'
        module_stream_ids = repo_associations_to_destroy.pluck(:module_stream_id)
        filter_rules = ::Katello::ContentViewModuleStreamFilterRule.
          in_content_views(affected_content_view_ids).where(module_stream_id: module_stream_ids)
        filter_rules.delete_all
      when 'Katello::Erratum'
        errata_ids = ::Katello::Erratum.where(id: repo_associations_to_destroy.select(:erratum_id)).pluck(:errata_id)
        filter_rules = ::Katello::ContentViewErratumFilterRule.in_content_views(affected_content_view_ids).where(errata_id: errata_ids)
        filter_rules.delete_all
      when 'Katello::PackageGroup'
        package_group_uuids = ::Katello::PackageGroup.where(id: repo_associations_to_destroy.select(:package_group_id)).pluck(:pulp_id)
        filter_rules = ::Katello::ContentViewPackageGroupFilterRule.
          in_content_views(affected_content_view_ids).where(uuid: package_group_uuids)
        filter_rules.delete_all
      else
        return false
      end
    end

    def association_class_uniqiness_attributes
      columns = [@model_class.unit_id_field, 'repository_id']
      found = ActiveRecord::Base.connection.indexes(@model_class.repository_association_class.table_name).find do |index|
        index.columns.sort == columns.sort
      end
      if found
        found.columns
      else
        fail "Unable to find unique index for #{columns} on table #{self.repository_association_class.table_name}"
      end
    end
  end
end
