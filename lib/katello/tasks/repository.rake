namespace :katello do
  def commit?
    ENV['COMMIT'] == 'true' || ENV['FOREMAN_UPGRADE'] == '1'
  end

  desc "Regnerate metadata for all repositories. Specify CONTENT_VIEW=name and LIFECYCLE_ENVIRONMENT=name to narrow repositories."
  task :regenerate_repo_metadata => ["dynflow:client", "check_ping"] do
    User.current = User.anonymous_api_admin
    repos = lookup_repositories

    if repos.any?
      task = ForemanTasks.async_task(Actions::Katello::Repository::BulkMetadataGenerate, repos.all.order_by_root(:name))
      puts "Regenerating #{repos.count} repositories.  You can monitor these on task id #{task.id}\n"
    else
      puts "No repositories found for regeneration."
    end
  end

  desc "Refresh repository metadata for all repositories. Specify CONTENT_VIEW=name and LIFECYCLE_ENVIRONMENT=name to narrow repositories."
  task :refresh_pulp_repo_details => ["dynflow:client", "check_ping"] do
    User.current = User.anonymous_api_admin
    repos = lookup_repositories

    if repos.any?
      task = ForemanTasks.async_task(::Actions::BulkAction, Actions::Katello::Repository::RefreshRepository, repos.all.order_by_root(:name))
      puts "Refreshing #{repos.count} repositories.  You can monitor these on task id #{task.id}\n"
    else
      puts "No repositories found for regeneration."
    end
  end

  desc "Correct missing pulp repositories. Specify CONTENT_VIEW=name and LIFECYCLE_ENVIRONMENT=name to narrow repositories.  COMMIT=true to perform operation."
  task :correct_repositories => ["environment", "check_ping"] do
    puts "All operations will be skipped.  Re-run with COMMIT=true to perform corrections." unless commit?

    User.current = User.anonymous_api_admin
    repos = lookup_repositories

    repos.find_each.with_index do |repo, index|
      puts "Processing Repository #{index + 1}/#{repos.count}: #{repo.name} (#{repo.id})"
      unless repo_exists?(repo)
        handle_missing_repo(repo)
      end
    end

    ::Katello::RootRepository.orphaned.each do |root_repo|
      handle_missing_root_repo(root_repo)
    end
  end

  desc "Change the download policy of all repos. Specify DOWNLOAD_POLICY=policy. Options are immediate or on_demand."
  task :change_download_policy => ["environment", "check_ping"] do
    policy = ENV['DOWNLOAD_POLICY']
    unless ::Katello::RootRepository::DOWNLOAD_POLICIES.include?(policy)
      puts "Invalid download policy specified: '#{policy}'. "
      puts "Options are immediate or on_demand."
      next
    end

    User.current = User.anonymous_api_admin
    repos = Katello::Repository.yum_type.where(library_instance_id: nil)

    repos.find_each.with_index do |repo, index|
      puts "Processing Repository #{index + 1}/#{repos.count}: #{repo.name} (#{repo.id})"
      begin
        ForemanTasks.sync_task(::Actions::Katello::Repository::Update, repo.root,
                               download_policy: policy)
      rescue => e
        puts "Failed to update repository #{repo.name} (#{repo.id}): #{e.message}"
      end
    end
  end

  desc "Re-import all container manifests and lists to populate labels and annotations."
  task :import_container_manifest_labels => ["dynflow:client", "check_ping"] do
    User.current = User.anonymous_api_admin
    handle_manifest_label_updates
    handle_manifest_list_label_updates
  end

  def lookup_repositories
    lifecycle_envs = Katello::KTEnvironment.where(:name => ENV['LIFECYCLE_ENVIRONMENT']) if ENV['LIFECYCLE_ENVIRONMENT']
    content_views = Katello::ContentView.where(:name => ENV['CONTENT_VIEW']) if ENV['CONTENT_VIEW']

    repos = ::Katello::Repository
    repos = repos.in_environment(lifecycle_envs) if lifecycle_envs
    repos = repos.in_content_views(content_views) if content_views
    repos
  end

  def repo_exists?(repo)
    if SmartProxy.pulp_primary!.pulp3_support?(repo)
      backend_service = repo.backend_service(SmartProxy.pulp_primary!)
      return false unless backend_service&.repository_reference&.repository_href
      backend_service.api.repositories_api.read(backend_service.repository_reference.repository_href)
    else
      false
    end
    true
  rescue StandardError => e
    return false if e.code == 404
  end

  def handle_missing_repo(repo)
    puts "Repository #{repo.id} Missing"
    if repo.content_view.default?
      puts "Recreating #{repo.id}"
      if commit?
        ForemanTasks.sync_task(::Actions::Katello::Repository::Create, repo, force_repo_create: true)
        repo.reload.index_content
      end
    else
      puts "Deleting #{repo.id}"
      ForemanTasks.sync_task(::Actions::Katello::Repository::Destroy, repo) if commit?
    end
  end

  def handle_manifest_updates(model_class)
    batch_size = 1000
    content_type = model_class::CONTENT_TYPE
    model_class.
     where(schema_version: 2).
     where(annotations: {}, labels: {}).
     where(is_bootable: false, is_flatpak: false).
     find_in_batches(batch_size: batch_size) do |group|
      manifest_unit_ids = group.pluck(:pulp_id)
      index_service = Katello::ContentUnitIndexer.new(
       content_type: Katello::RepositoryTypeManager.find_content_type(content_type),
       pulp_content_ids: manifest_unit_ids
      )
      index_service.reimport_units
    end
  end

  def handle_manifest_label_updates
    handle_manifest_updates(Katello::DockerManifest)
  end

  def handle_manifest_list_label_updates
    handle_manifest_updates(Katello::DockerManifestList)
  end

  def handle_missing_root_repo(root_repo)
    root_repo.destroy! if commit?
  end
end
