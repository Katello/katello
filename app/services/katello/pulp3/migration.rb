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

      MUTABLE_CONTENT_TYPES = [
        Katello::DockerTag,
        Katello::Erratum
      ].freeze

      def initialize(smart_proxy, repository_types = REPOSITORY_TYPES)
        if (repository_types - smart_proxy.supported_pulp_types[:pulp3][:overriden_to_pulp2]).any?
          fail ::Katello::Errors::Pulp3MigrationError, _("Pulp 3 migration cannot run. Types %s have already been migrated.") %
            (repository_types - smart_proxy.supported_pulp_types[:pulp3][:overriden_to_pulp2]).join(', ')
        end

        @repository_types = repository_types
        @smart_proxy = smart_proxy
      end

      def api_client
        Pulp2to3MigrationClient::ApiClient.new(smart_proxy.pulp3_configuration(Pulp2to3MigrationClient::Configuration))
      end

      def migration_plan_api
        Pulp2to3MigrationClient::MigrationPlansApi.new(api_client)
      end

      def pulp2_content_api
        Pulp2to3MigrationClient::Pulp2ContentApi.new(api_client)
      rescue NameError
        Pulp2to3MigrationClient::Pulp2contentApi.new(api_client) #backwards compatible
      end

      def pulp2_repositories_api
        Pulp2to3MigrationClient::Pulp2RepositoriesApi.new(api_client)
      rescue NameError
        Pulp2to3MigrationClient::Pulp2repositoriesApi.new(api_client) #backwards compatible
      end

      def create_and_run_migrations
        create_migrations.map { |href| start_migration(href) }
      end

      def content_types_for_migration
        content_types = @repository_types.collect do |repository_type_label|
          Katello::RepositoryTypeManager.repository_types[repository_type_label].content_types_to_index
        end

        content_types.flatten
      end

      def import_pulp3_content
        @repository_types.each do |repository_type_label|
          Katello::RepositoryTypeManager.repository_types[repository_type_label].content_types_to_index.each do |content_type|
            import_content_type(content_type)
          end
          import_repositories(repository_type_label)
        end
      end

      def create_migrations
        migration_plans = @repository_types.map { |label| Katello::Pulp3::MigrationPlan.new(label) }
        migration_plans.map { |plan| migration_plan_api.create(plan: plan.generate.as_json).pulp_href }
      end

      def start_migration(plan_href)
        migration_plan_api.run(plan_href, dry_run: false)
      end

      def import_repositories(repository_type_label)
        imported = Katello::Pulp3::Api::Core.fetch_from_list { |opts| pulp2_repositories_api.list(opts) }
        imported = imported.select { |migrated| !migrated.not_in_plan }

        Katello::Repository.with_type(repository_type_label).each do |repo|
          found = imported.find { |migrated_repo| migrated_repo.pulp2_repo_id == repo.pulp_id }
          import_repo(repo, found) if found
        end
      end

      def api_for_repository(katello_repo)
        katello_repo.repository_type.pulp3_api_class
      end

      def import_repo(katello_repo, migrated_repo)
        pulp3_api = api_for_repository(katello_repo).new(SmartProxy.pulp_master)
        katello_repo.remote_href = migrated_repo.pulp3_remote_href
        katello_repo.publication_href = migrated_repo.pulp3_publication_href
        katello_repo.version_href = migrated_repo.pulp3_repository_version
        katello_repo.save!

        if katello_repo.environment_id.nil? #a cv archive repo
          environment_instances = Katello::Repository.where(library_instance_id: katello_repo.library_instance_id,
                                                            content_view_version_id: katello_repo.content_view_version_id)
          environment_instances.update_all(publication_href: migrated_repo.pulp3_publication_href, version_href: migrated_repo.pulp3_repository_version)
        end

        repo_ref = Katello::Pulp3::RepositoryReference.find_or_initialize_by(:root_repository_id => katello_repo.root_id, :content_view_id => katello_repo.content_view.id)
        repo_ref.repository_href = migrated_repo.pulp3_repository_href
        repo_ref.save!

        process_distributions(pulp3_api, migrated_repo.pulp3_distribution_hrefs)
      end

      def process_distributions(pulp3_api, dist_hrefs_list)
        #distribution_path_hash(pulp3_api, dist_hrefs_list).each do |relative_path, href|
        dist_hrefs_list.each do |href|
          relative_path = pulp3_api.distributions_api.read(href).base_path

          dist_ref = Katello::Pulp3::DistributionReference.find_or_initialize_by(:path => relative_path)
          if (distribution_repo = Katello::Repository.find_by(:relative_path => relative_path))
            dist_ref.href = href
            dist_ref.repository_id = distribution_repo.id
            dist_ref.save!
          end
        end
      end

      def import_content_type(content_type)
        unmigrated_units = content_type.model_class
        #mutable content types have to be completely re-indexed every time
        unless MUTABLE_CONTENT_TYPES.include?(content_type.model_class)
          unmigrated_units = unmigrated_units.where(:migrated_pulp3_href => nil)
        end
        unmigrated_units.select(:id, :pulp_id).find_in_batches(batch_size: GET_QUERY_ID_LENGTH) do |needing_hrefs|
          migrated_units = pulp2_content_api.list(pulp2_id__in: needing_hrefs.map { |unit| unit.pulp_id }.join(','))
          migrated_units.results.each do |migrated_unit|
            matching_record = needing_hrefs.find { |db_unit| db_unit.pulp_id == migrated_unit.pulp2_id }

            matching_record&.update_column(:migrated_pulp3_href, migrated_unit.pulp3_content)
          end
        end
      end
    end
  end
end
