namespace :katello do
  namespace :upgrades do
    namespace '4.21' do
      desc "Destroy all PythonPublication objects from Pulp database"
      task :cleanup_python_publications => ["environment"] do
        User.current = User.anonymous_api_admin

        python_repos = Katello::Repository.joins(:root).where(katello_root_repositories: { content_type: 'python' })
        if python_repos.empty?
          puts "No python repositories found. Skipping upgrade task."
          next
        end

        smart_proxy = SmartProxy.pulp_primary
        unless smart_proxy
          puts "ERROR: Primary Pulp smart proxy not found."
          exit 1
        end

        migrate_distributions(python_repos, smart_proxy)
        delete_python_publications(smart_proxy)
        clear_publication_hrefs(python_repos)
      end

      # rubocop:disable Metrics/MethodLength
      def self.migrate_distributions(python_repos, smart_proxy)
        puts "Migrating Python distributions from publications to repository_versions..."
        tasks = []
        migration_failed = false
        repos_needing_migration = python_repos.select { |repo| repo.environment.present? && repo.publication_href.present? }
        repos_needing_migration.each do |repo|
          begin
            service = Katello::Pulp3::Repository.instance_for_type(repo, smart_proxy)
            repo_tasks = service.update_distribution
            tasks.concat(repo_tasks) if repo_tasks.present?
            puts "Migrating distribution for repository: #{repo.name} (ID: #{repo.id})"
          rescue StandardError => e
            puts "ERROR: Failed to update distribution for repository #{repo.name} (ID: #{repo.id}): #{e.message}"
            migration_failed = true
          end
        end

        # Wait for all distribution update tasks to complete
        if tasks.any?
          puts "Waiting for #{tasks.count} distribution update tasks to complete..."
          task_objects = tasks.map { |task_response| Katello::Pulp3::Task.new(smart_proxy, { 'task' => task_response.task }) }

          task_objects.each_with_index do |task, index|
            max_wait = 600 # 10 minutes per task
            elapsed = 0

            until task.done?
              if elapsed >= max_wait
                puts "\nERROR: Task #{index + 1}/#{tasks.count} timed out after #{max_wait} seconds"
                exit 1
              end
              print "."
              sleep 1
              elapsed += 1
              task.poll
            end

            if task.error
              puts "\nERROR: Task #{index + 1}/#{tasks.count} failed: #{task.error}"
              migration_failed = true
            else
              puts "\nTask #{index + 1}/#{tasks.count} completed successfully"
            end
          end
        end

        if migration_failed
          puts "ERROR: One or more distribution migrations failed."
          exit 1
        end
      end
      # rubocop:enable Metrics/MethodLength

      # rubocop:disable Metrics/MethodLength
      def self.delete_python_publications(smart_proxy)
        puts "Deleting Python publications from Pulp database..."
        python_repo_type = Katello::RepositoryTypeManager.find('python')
        unless python_repo_type
          puts "WARNING: Python repository type not found. Skipping Pulp cleanup."
          return
        end

        pulp_python_api = Katello::Pulp3::Api::Core.new(smart_proxy, python_repo_type)
        begin
          publications = pulp_python_api.publications_list_all
        rescue StandardError => e
          puts "ERROR: Failed to list Python publications from Pulp API: #{e.message}"
          exit 1
        end

        if publications.empty?
          puts "No Python publications found in Pulp database"
        else
          deleted_count = 0
          error_count = 0
          publications.each do |publication|
            begin
              puts "Deleting publication: #{publication.pulp_href}"
              pulp_python_api.publications_api.delete(publication.pulp_href)
              deleted_count += 1
            rescue RestClient::NotFound
              # Publication already deleted (404) - count as success
              deleted_count += 1
            rescue StandardError => e
              puts "ERROR: Failed to delete publication: #{e.message}"
              error_count += 1
            end
          end

          puts "Successfully deleted #{deleted_count} Python publications from Pulp"
          if error_count > 0
            puts "#{error_count} publications could not be deleted. Please review errors above. Re-run this rake task: 'katello:upgrades:4.21:cleanup_python_publications'"
            exit 1
          end
        end
      end

      def self.clear_publication_hrefs(python_repos)
        puts "Clearing publication_href references in Katello database..."
        begin
          repos_with_publications = python_repos.where.not(publication_href: nil)
          if repos_with_publications.any?
            count = repos_with_publications.count
            repos_with_publications.update_all(publication_href: nil)
            puts "Cleared publication_href from #{count} repositories"
          else
            puts "No repositories with publication_href found"
          end
        rescue StandardError => e
          puts "ERROR: Failed to clear publication_href from repository records. You may need to manually clear these references: #{e.message}"
          exit 1
        end
      end
    end
    # rubocop:enable Metrics/MethodLength
  end
end
