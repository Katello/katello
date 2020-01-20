require 'pulp_2to3_migration_client'

module Katello
  module Pulp3
    class Migration
      attr_accessor :smart_proxy
      GET_QUERY_ID_LENGTH = 90

      REPOSITORY_TYPES = [
        Katello::Repository::FILE_TYPE,
        Katello::Repository::DOCKER_TYPE
      ].freeze

      def initialize(smart_proxy, repository_type_labels)
        @smart_proxy = smart_proxy
        @repository_type_labels = repository_type_labels
      end

      def api_client
        Pulp2to3MigrationClient::ApiClient.new(smart_proxy.pulp3_configuration(Pulp2to3MigrationClient::Configuration))
      end

      def migration_plan_api
        Pulp2to3MigrationClient::MigrationPlansApi.new(api_client)
      end

      def pulp2_content_api
        Pulp2to3MigrationClient::Pulp2contentApi.new(api_client)
      end

      def create_and_run_migration
        start_migration(create_migration)
      end

      def self.content_types_for_migration
        content_types = REPOSITORY_TYPES.collect do |repository_type_label|
          Katello::RepositoryTypeManager.repository_types[repository_type_label].content_types_to_index
        end

        content_types.flatten
      end

      def import_pulp3_content
        @repository_type_labels.each do |repository_type_label|
          Katello::RepositoryTypeManager.repository_types[repository_type_label].content_types_to_index.each do |content_type|
            import_content_type(content_type)
          end
        end
      end

      def create_migration
        migration_plan = Katello::Pulp3::MigrationPlan.new(@repository_type_labels)
        migration_plan_api.create(plan: migration_plan.generate).pulp_href
      end

      def start_migration(plan_href)
        migration_plan_api.run(plan_href, dry_run: false)
      end

      def import_content_type(content_type)
        content_type.model_class.where(:migrated_pulp3_href => nil).select(:id, :pulp_id).find_in_batches(batch_size: GET_QUERY_ID_LENGTH) do |needing_hrefs|
          migrated_units = pulp2_content_api.list(pulp2_id__in: needing_hrefs.map { |unit| unit.pulp_id }.join(','))
          migrated_units.results.each do |migrated_unit|
            matching_record = needing_hrefs.find { |db_unit| db_unit.pulp_id == migrated_unit.pulp2_id }
            matching_record.update_column(:migrated_pulp3_href, migrated_unit.pulp3_content) if matching_record
          end
        end
      end
    end
  end
end
