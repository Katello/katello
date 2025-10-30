namespace :katello do
  namespace :upgrades do
    namespace '4.19' do
      desc "Migrate all APT repo content using simple mode to use structured APT mode."
      task :enable_structured_apt_for_deb => ['environment', 'dynflow:client', "check_ping"] do
        ::ForemanTasks.dynflow.config.remote = true
        ::ForemanTasks.dynflow.initialize!

        User.current = User.anonymous_api_admin # Set a user

        roots = Katello::RootRepository.deb_type

        if roots.any?
          puts "Enabling structured APT for all deb type repos not already migrated."
        else
          puts "Since there are no deb type repos, enabling structured APT does not require migration. Skipping."
          exit
        end

        found_repos_to_migrate = false
        roots.includes(:repositories).each do |root|
          next unless root.content_id
          found_repos_to_migrate = true
          puts "Migrating root repo '#{root.name}', id='#{root.id}'."

          # Ensure ensure_valid_deb_constraints won't prevent us from saving the root repo.
          unless root.ensure_valid_deb_constraints.blank?
            puts "Root repo '#{root.name}' (id='#{root.id}') violates deb constraints, setting url and deb_releases to nil!"
            root.url = nil
            root.deb_releases = nil
          end

          repos = root.repositories
          library_instance = root.library_instance
          if root.content_id != 'NEEDS_RE_MIGRATION'
            begin
              # Move the content_id from the root to the library instance so that ContentDestroy will destroy it!
              old_content_id = root.content_id
              library_instance.content_id = old_content_id
              library_instance.save!
              root.content_id = nil
              root.save!
              ForemanTasks.sync_task(::Actions::Katello::Product::ContentDestroy, root.library_instance)
              library_instance.content_id = nil
              library_instance.save!
            rescue
              root.content_id = old_content_id
              root.save!
              library_instance.content_id = nil
              library_instance.save!
              raise
            end
          end
          begin
            root.content_id = nil
            root.save!

            repos.each do |repo|
              if repo[:content_id].nil?
                content_create = ForemanTasks.sync_task(::Actions::Katello::Product::ContentCreate, repo)
                content_id = content_create.input[:content_id]
              else
                content_id = repo.content_id
              end
              content_view_environment = repo.content_view_environment
              if content_view_environment
                ForemanTasks.sync_task(::Actions::Candlepin::Environment::AddContentToEnvironment, :view_env_cp_id => content_view_environment.cp_id, :content_id => content_id)
              end
            end
          rescue
            root.content_id = 'NEEDS_RE_MIGRATION'
            root.save!
            raise
          end
          puts "Successfully migrated root repo '#{root.name}', id='#{root.id}'."
        end

        if found_repos_to_migrate
          puts "Successfully migrated all remaining repositories to use structured APT!"
          puts "IMPORTANT: Any smart proxies serving deb content that was migrated must be re-synced!"
        else
          puts "Found no repositories that needed migrating. All existing deb type repos are already using structured APT!"
        end
      end
    end
  end
end
