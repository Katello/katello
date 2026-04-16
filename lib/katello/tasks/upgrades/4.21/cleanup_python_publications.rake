namespace :katello do
  namespace :upgrades do
    namespace '4.21' do
      desc "Destroy all PythonPublication objects from Pulp database"
      task :cleanup_python_publications => ["environment"] do
        # Clear publication_href references in Katello Python repositories
        begin
          python_repos = Katello::Repository.joins(:root).where(katello_root_repositories: { content_type: 'python' })
          repos_with_publications = python_repos.where.not(publication_href: nil)
          if repos_with_publications.any?
            repos_with_publications.update_all(publication_href: nil)
          end
        rescue StandardError => e
          puts "ERROR: Failed to clear publication_href from repository records: #{e.message}"
          puts "You may need to manually clear these references."
        end
        
        # Clear all PythonPublication objects in Pulp database
        # This does not destroy orphans; the best way to do that is full orphan cleanup. Not needed in this task.
        User.current = User.anonymous_api_admin
        python_repo_type = Katello::RepositoryTypeManager.find('python')
        unless python_repo_type
          puts "Python repository type not found. Skipping Pulp cleanup."
          next
        end
        smart_proxy = SmartProxy.pulp_primary
        unless smart_proxy
          puts "Primary Pulp smart proxy not found. Skipping Pulp cleanup."
          next
        end
        python_api = Katello::Pulp3::Api::Core.new(smart_proxy, python_repo_type)

        begin
          publications = python_api.publications_list_all
        rescue StandardError => e
          puts "ERROR: Failed to list Python publications from Pulp API: #{e.message}"
          puts e.backtrace.join("\n")
          exit 1
        end
        if publications.empty?
          puts "No Pulp Python publications found. Skipping Pulp cleanup."
          next
        end

        deleted_count = 0
        error_count = 0
        publications.each do |publication|
          begin
            puts "Deleting Pulp publication: #{publication.pulp_href}"
            python_api.publications_api.delete(publication.pulp_href)
            deleted_count += 1
          rescue RestClient::NotFound
            # Publication already deleted (404) - count as success
            deleted_count += 1
          rescue StandardError => e
            puts "ERROR: Failed to delete Pulp publication: #{e.message}"
            error_count += 1
          end
        end

        puts "Successfully deleted #{deleted_count} Python-type publications from Pulp"
        if error_count > 0
          puts "WARNING: Some publications could not be deleted. Please review errors above."
          puts "Re-run this rake task before Katello use: 'katello:upgrades:4.21:cleanup_python_publications'"
          exit 1
        end
      end
    end
  end
end
