namespace :katello do
  def commit?
    ENV['COMMIT'] == 'true' || ENV['FOREMAN_UPGRADE'] == '1'
  end

  desc "Check for repositories that have not been published since their last sync, and republish if they have."
  task :publish_unpublished_repositories => ["dynflow:client", "check_ping"] do
    needing_publish = []
    Organization.find_each do |org|
      if org.default_content_view && !org.default_content_view.versions.empty?
        org.default_content_view.versions.first.repositories.joins(:root)
          .where.not(katello_root_repositories: { url: nil }).find_each do |repo|
          if repo.needs_metadata_publish?
            Rails.logger.error("Repository metadata for #{repo.name} (#{repo.id}) is out of date, regenerating.")
            needing_publish << repo.id
          end
        rescue => e
          puts "Failed to check repository #{repo.id}: #{e}"
        end
      end
    end
    if needing_publish.any?
      ForemanTasks.async_task(::Actions::Katello::Repository::BulkMetadataGenerate, Katello::Repository.where(:id => needing_publish))
    end
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

  desc "Change the download policy of all repos. Specify DOWNLOAD_POLICY=policy. Options are #{::Runcible::Models::YumImporter::DOWNLOAD_POLICIES.join(', ')}."
  task :change_download_policy => ["environment", "check_ping"] do
    policy = ENV['DOWNLOAD_POLICY']
    unless ::Runcible::Models::YumImporter::DOWNLOAD_POLICIES.include?(policy)
      puts "Invalid download policy specified: '#{policy}'. "
      puts "Options are #{::Runcible::Models::YumImporter::DOWNLOAD_POLICIES.to_sentence}."
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

  desc "Refresh pulp sync schedules"
  task :refresh_sync_schedule => ["environment", "check_ping"] do
    User.current = User.anonymous_api_admin
    Katello::Product.all.each do |product|
      puts "Updating #{product}"
      ForemanTasks.sync_task(::Actions::Pulp::Repos::Update, product)
    end
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
      Katello.pulp_server.extensions.repository.retrieve(repo.pulp_id)
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

  def handle_missing_root_repo(root_repo)
    root_repo.destroy! if commit?
  end
end
