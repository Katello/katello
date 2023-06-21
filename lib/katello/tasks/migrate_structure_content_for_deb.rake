namespace :katello do
  desc "Migrate all APT repo content to match the deb_enable_structured_apt setting."
  task :migrate_structure_content_for_deb => ['environment', 'dynflow:client', "check_ping"] do
    User.current = User.anonymous_api_admin # Set a user

    deb_enable_structured_apt = Setting['deb_enable_structured_apt']
    puts "'Enable structured APT for deb content' is currently set to '#{deb_enable_structured_apt}'!"
    if deb_enable_structured_apt
      puts "Enabling structured APT for existing deb type repos."
    else
      puts "Disabling structured APT for existing deb type repos."
    end

    found_repos_to_migrate = false
    roots = Katello::RootRepository.deb_type
    roots.each do |root|
      next if root.deb_using_structured_apt? == deb_enable_structured_apt
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
      if deb_enable_structured_apt
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
      else
        library_instance_content_id = library_instance.content_id

        repos.each do |repo|
          next if repo.library_instance?

          content_view_environment = repo.content_view_environment
          if content_view_environment
            ForemanTasks.sync_task(::Actions::Candlepin::Environment::AddContentToEnvironment, :view_env_cp_id => content_view_environment.cp_id, :content_id => library_instance_content_id)
          end
          ForemanTasks.sync_task(::Actions::Katello::Product::ContentDestroy, repo)
          repo.content_id = nil
          repo.save!
        end

        root.content_id = library_instance_content_id
        library_instance.content_id = nil
        root.save!
        library_instance.save!
        ForemanTasks.sync_task(::Actions::Katello::Repository::Update, root, {})
        repos.each do |repo|
          ForemanTasks.sync_task(::Actions::Katello::Repository::MetadataGenerate, repo, force_publication: true)
        end
      end
      puts "Successfully migrated root repo '#{root.name}', id='#{root.id}'."
    end

    if found_repos_to_migrate
      puts "Successfully migrated all remaining repositories to be consistent with deb_enable_structured_apt='#{deb_enable_structured_apt}'!"
      puts "IMPORTANT: Any smart proxies serving deb content that was migrated must be re-synced!"
    else
      puts "Found no repositories that needed migrating. Everything is consistent with deb_enable_structured_apt='#{deb_enable_structured_apt}'!"
    end
  end
end
