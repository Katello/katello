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
      @other_time = 0
      @import_time = 0
      @assoc_time = 0
    end

    def report
      Rails.logger.error("Times: #{@other_time}, #{@import_time}, #{@assoc_time}")
    end

    def import_time
      a = Time.now
      to_return = yield
      @import_time += (Time.now - a)
      to_return
    end

    def other_time
      a = Time.now
      to_return = yield
      @other_time += (Time.now - a)
      to_return
    end

    def assoc_time
      a = Time.now
      to_return = yield
      @assoc_time += (Time.now - a)
      to_return
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

    def import_all
      association_tracker = RepoAssociationTracker.new(@content_type, @service_class, @repository)

      units_from_pulp.each do |units|
        to_insert = units.map do |unit|
          association_tracker.push(unit)
          remove_duplicates(unit)
          if @content_type.generic?
            other_time { @service_class.generate_model_row(unit, @content_type) }
          else
            other_time { @service_class.generate_model_row(unit) }
          end
        end

        next if to_insert.empty?
        insert_timestamps(to_insert)
        if @content_type.mutable
          import_time { @model_class.upsert_all(to_insert, unique_by: :pulp_id) }
        else
          import_time { @model_class.insert_all(to_insert, unique_by: :pulp_id) }
        end

        import_associations(units) if @repository
      end

      if @model_class.many_repository_associations && @repository
        assoc_time { sync_repository_associations(association_tracker) } #:pulp_ids => ids_to_associate, :additive => true) }
      end
      @service_class.report
      report
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
          @model_class.repository_association_class.where(repository_id: @repository.id).where.
            not(@model_class.unit_id_field => assocication_tracker.unit_ids).delete_all
        end
      end
      return if assocication_tracker.db_values.empty?
      @model_class.repository_association_class.upsert_all(assocication_tracker.db_values, :unique_by => association_class_uniqiness_attributes)
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
  end
end
