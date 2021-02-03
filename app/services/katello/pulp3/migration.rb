require 'pulp_2to3_migration_client'

module Katello
  module Pulp3
    class Migration
      attr_accessor :smart_proxy, :reimport_all, :task_id
      GET_QUERY_ID_LENGTH = 90

      MUTABLE_CONTENT_TYPES = [
        Katello::DockerTag,
        Katello::Erratum
      ].freeze

      UNIFIED_CONTENT_TYPES = [
        Katello::Erratum
      ].freeze

      def self.repository_types_for_migration
        #we can migrate types that pulp3 supports, but are overridden to pulp2.  These are in 'migration mode'
        overridden = (SETTINGS[:katello][:use_pulp_2_for_content_type] || {}).keys.select { |key| SETTINGS[:katello][:use_pulp_2_for_content_type][key] }
        overridden.select { |type| SmartProxy.pulp_primary.pulp3_repository_type_support?(type.to_s, false) }.map { |t| t.to_s }
      end

      def initialize(smart_proxy, options = {})
        self.task_id = options.fetch(:task_id, nil)
        self.reimport_all = options.fetch(:reimport_all, false)
        repository_types = options.fetch(:repository_types, Migration.repository_types_for_migration)

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
        migs = create_migrations
        migs.map { |href| start_migration(href) }
      end

      def self.ignorable_content_types
        [YumMetadataFile]
      end

      def last_successful_migration_time
        task = ForemanTasks::Task.where(:label => Actions::Pulp3::ContentMigration.to_s, :result => 'success').order("started_at desc").first
        if reimport_all || task.nil?
          0
        else
          task.started_at.to_i
        end
      end

      def content_types_for_migration
        content_types = @repository_types.collect do |repository_type_label|
          Katello::RepositoryTypeManager.repository_types[repository_type_label].content_types_to_index
        end

        content_types.flatten - Migration.ignorable_content_types
      end

      def update_import_status(message, index = nil)
        #reduce output updating, only update every 20 items
        if (index.nil? || index % 20 == 0) && self.task_id
          progress = Katello::ContentMigrationProgress.find_or_create_by(:task_id => self.task_id)
          progress.update(:progress_message => message)
          progress.save!

          fail Katello::Errors::Pulp3MigrationError, "Cancelled by user." if progress.canceled?
        end
      end

      def import_pulp3_content
        update_import_status("Starting katello import phase.")

        Katello::Logging.time("CONTENT_MIGRATION - Total Import Process") do
          @repository_types.each do |repository_type_label|
            Katello::Logging.time("CONTENT_MIGRATION - Importing Repository", data: {type: repository_type_label}) do
              import_repositories(repository_type_label)
            end

            Katello::RepositoryTypeManager.repository_types[repository_type_label].content_types_to_index.each do |content_type|
              Katello::Logging.time("CONTENT_MIGRATION - Importing Content", data: {type: content_type.label}) do
                import_content_type(content_type)
              end
            end
          end
        end
      end

      def migration_plan
        Katello::Pulp3::MigrationPlan.new(@repository_types).generate.as_json
      end

      def reset
        if @repository_types.empty?
          fail ::Katello::Errors::Pulp3MigrationError, 'There are no Pulp 3 content types to reset'
        end

        plugins = @repository_types.sort.map do |repository_type|
          {
            type: ::Katello::Pulp3::MigrationPlan.pulp2_repository_type(repository_type)
          }
        end
        plan = { plugins: plugins }

        # TODO: Don't provide the plan as a string once this is resolved: https://pulp.plan.io/issues/8211
        migration_plan_api.reset(migration_plan_api.create(plan: plan).pulp_href, plan.to_json)

        content_types_for_migration.each do |content_type|
          if content_type.model_class == ::Katello::Erratum
            ::Katello::RepositoryErratum.update_all(erratum_pulp3_href: nil)
          else
            content_type.model_class.update_all(migrated_pulp3_href: nil)
          end
        end

        @repository_types.each do |repo_type|
          if repo_type == "file"
            ::Katello::Repository.file_type.update(remote_href: nil, publication_href: nil, version_href: nil)
          elsif repo_type == "docker"
            ::Katello::Repository.docker_type.update(remote_href: nil, publication_href: nil, version_href: nil)
          elsif repo_type == "yum"
            ::Katello::Repository.yum_type.update(remote_href: nil, publication_href: nil, version_href: nil)
          end
        end

        ::Katello::Pulp3::RepositoryReference.destroy_all
        ::Katello::Pulp3::DistributionReference.destroy_all
        ::Katello::Pulp3::ContentGuard.destroy_all
      end

      def create_migrations
        plan = migration_plan
        Rails.logger.info("Migration Plan: #{plan}")

        if plan['plugins'].empty?
          Rails.logger.error("No Repositories to migrate")
          []
        else
          [migration_plan_api.create(plan: plan).pulp_href]
        end
      end

      def start_migration(plan_href)
        migration_plan_api.run(plan_href, dry_run: false, validate: true)
      end

      def import_repositories(repository_type_label)
        imported = Katello::Pulp3::Api::Core.fetch_from_list { |opts| pulp2_repositories_api.list(opts) }
        imported = imported.select { |migrated| !migrated.not_in_plan }
        katello_repos = Katello::Repository.with_type(repository_type_label)

        if repository_type_label == 'yum'
          import_yum_repos(imported, katello_repos)
        else
          repo_count = katello_repos.count
          katello_repos.each_with_index do |repo, index|
            update_import_status("Importing migrated content units #{repository_type_label}: #{index + 1}/#{repo_count}", index)
            found = imported.find { |migrated_repo| migrated_repo.pulp2_repo_id == repo.pulp_id }
            import_repo(repo, found) if found
          end
        end
      end

      def import_yum_repos(migrated_repo_items, repos)
        repo_count = repos.count
        repos.each_with_index do |yum_repo, index|
          update_import_status("Importing migrated yum repositories: #{index + 1}/#{repo_count}", index)
          to_find = nil
          if yum_repo.content_view.composite?
            if yum_repo.link?
              to_find = yum_repo.target_repository
            else
              to_find = yum_repo
            end
          elsif yum_repo.environment_id.nil? || yum_repo.in_default_view? #non-composite archive repo or default content view repo
            to_find = yum_repo
          else #non-composite env-repo
            to_find = yum_repo.archived_instance
          end

          if to_find
            found = migrated_repo_items.find { |migrated_repo| migrated_repo.pulp2_repo_id == to_find.pulp_id }
            import_repo(yum_repo, found)
          end
        end
      end

      def api_for_repository(katello_repo)
        katello_repo.repository_type.pulp3_api_class
      end

      def import_repo(katello_repo, migrated_repo)
        pulp3_api = api_for_repository(katello_repo).new(SmartProxy.pulp_primary)
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
        repo_ref.update!(repository_href: migrated_repo.pulp3_repository_href) if repo_ref.repository_href != migrated_repo.pulp3_repository_href
        process_distributions(pulp3_api, migrated_repo.pulp3_distribution_hrefs)
      end

      def distribution_path_from_cache(href, pulp3_api)
        @distribution_cache ||= {}
        @distribution_cache[href] ||= pulp3_api.distributions_api.read(href).base_path
        @distribution_cache[href]
      end

      def process_distributions(pulp3_api, dist_hrefs_list)
        #distribution_path_hash(pulp3_api, dist_hrefs_list).each do |relative_path, href|
        dist_hrefs_list.each do |href|
          relative_path = distribution_path_from_cache(href, pulp3_api)

          dist_ref = Katello::Pulp3::DistributionReference.find_or_initialize_by(:path => relative_path)
          if (distribution_repo = Katello::Repository.find_by(:relative_path => relative_path) || Katello::Repository.find_by(:container_repository_name => relative_path))
            dist_ref.href = href
            dist_ref.repository_id = distribution_repo.id
            dist_ref.save!
          end
        end
      end

      def generate_repo_version_map
        map = {}
        Katello::Repository.select(:id, :version_href).each do |repo|
          map[repo.version_href] ||= []
          map[repo.version_href] << repo.id
        end
        map
      end

      def operate_on_errata
        last_migration_time = last_successful_migration_time
        offset = 0
        limit = SETTINGS[:katello][:pulp][:bulk_load_size]
        response = pulp2_content_api.list(pulp2_content_type_id: 'erratum', offset: offset, limit: limit, pulp2_last_updated__gt: last_migration_time)
        total_count = response.count
        yield(response.results)
        until (offset + limit > total_count)
          offset += limit
          response = pulp2_content_api.list(pulp2_content_type_id: 'erratum', offset: offset, limit: limit, pulp2_last_updated__gt: last_migration_time)
          update_import_status("Importing migrated content type erratum: #{offset + limit}/#{total_count}")
          yield(response.results)
        end
      end

      def import_errata
        to_import = {}

        repo_version_map = generate_repo_version_map

        operate_on_errata do |migrated_list|
          katello_errata = Katello::Erratum.where(:pulp_id => migrated_list.map(&:pulp2_id).uniq)
          migrated_list.each do |migrated_unit|
            pulp3_href = migrated_unit.pulp3_content
            errata_id = katello_errata.find { |erratum| erratum.pulp_id == migrated_unit.pulp2_id }&.id
            next if errata_id.nil?
            repo_ids = repo_version_map[migrated_unit.pulp3_repository_version]
            #currently pulp can have duplicates, so de-duplicate with a hash
            repo_ids&.each do |repo_id|
              #currently pulp can have duplicates, so de-duplicate with a hash
              to_import[[errata_id, repo_id]] ||= {erratum_id: errata_id, erratum_pulp3_href: pulp3_href, repository_id: repo_id}
            end
          end
        end

        Katello::RepositoryErratum.import([:erratum_id, :erratum_pulp3_href, :repository_id], to_import.values, :validate => false,
                                          on_duplicate_key_update: {conflict_target: [:erratum_id, :repository_id], columns: [:erratum_pulp3_href]})
      end

      def import_content_type(content_type)
        if content_type.model_class == Katello::Erratum
          import_errata
        else
          unmigrated_units = content_type.model_class

          #mutable content types have to be completely re-indexed every time
          if !MUTABLE_CONTENT_TYPES.include?(content_type.model_class) && !self.reimport_all
            unmigrated_units = unmigrated_units.where(:migrated_pulp3_href => nil)
          end

          total_count = unmigrated_units.count
          current_count = 0

          unmigrated_units.select(:id, :pulp_id).find_in_batches(batch_size: GET_QUERY_ID_LENGTH) do |needing_hrefs|
            current_count += needing_hrefs.count
            update_import_status("Importing migrated content type #{content_type.label}: #{current_count}/#{total_count}")
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
end
