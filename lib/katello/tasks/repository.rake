namespace :katello do
  task :disable_dynflow do
    ForemanTasks.dynflow.config.remote = true
  end

  desc "Regnerate metadata for all repositories. Specify CONTENT_VIEW=name and LIFECYCLE_ENVIRONMENT=name to narrow repositories."
  task :regenerate_repo_metadata => ["environment", "disable_dynflow", "check_ping"] do
    User.current = User.anonymous_api_admin
    repos = lookup_repositories

    if repos.any?
      task = ForemanTasks.async_task(::Actions::BulkAction, Actions::Katello::Repository::MetadataGenerate, repos.all.sort)
      puts "Regenerating #{repos.count} repositories.  You can monitor these on task id #{task.id}\n"
    else
      puts "No repositories found for regeneration."
    end
  end

  desc "Refresh repository metadata for all repositories. Specify CONTENT_VIEW=name and LIFECYCLE_ENVIRONMENT=name to narrow repositories."
  task :refresh_pulp_repo_details => ["environment", "disable_dynflow", "check_ping"] do
    User.current = User.anonymous_api_admin
    repos = lookup_repositories

    if repos.any?
      task = ForemanTasks.async_task(::Actions::BulkAction, Actions::Katello::Repository::RefreshRepository, repos.all.sort)
      puts "Refreshing #{repos.count} repositories.  You can monitor these on task id #{task.id}\n"
    else
      puts "No repositories found for regeneration."
    end
  end

  desc "Correct missing pulp repositories. Specify CONTENT_VIEW=name and LIFECYCLE_ENVIRONMENT=name to narrow repositories.  COMMIT=true to perform operation."
  task :correct_repositories => ["environment", "check_ping"] do
    puts "All operations will be skipped.  Re-run with COMMIT=true to perform corrections." if ENV['COMMIT'] != 'true'

    User.current = User.anonymous_api_admin
    repos = lookup_repositories

    repos.find_each.with_index do |repo, index|
      puts "Processing Repository #{index + 1}/#{repos.count}: #{repo.name} (#{repo.id})"
      unless repo_exists?(repo)
        handle_missing_repo(repo)
      end
    end
  end

  desc "Correct missing pulp repositories for puppet environments. Specify CONTENT_VIEW=name and LIFECYCLE_ENVIRONMENT=name to narrow repositories.  COMMIT=true to perform operation."
  task :correct_puppet_environments => ["environment", "check_ping"] do
    puts "All operations will be skipped.  Re-run with COMMIT=true to perform corrections." if ENV['COMMIT'] != 'true'

    User.current = User.anonymous_api_admin
    puppet_envs = lookup_puppet_environments

    puppet_envs.find_each.with_index do |puppet_env, index|
      puts "Processing Puppet Environment #{index + 1}/#{puppet_envs.count}: #{puppet_env.pulp_id} (#{puppet_env.id})"
      unless repo_exists?(puppet_env)
        handle_missing_puppet_env(puppet_env)
      end
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
        ForemanTasks.sync_task(::Actions::Katello::Repository::Update, repo,
                               download_policy: policy)
      rescue => e
        puts "Failed to update repository #{repo.name} (#{repo.id}): #{e.message}"
      end
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

  def lookup_puppet_environments
    lifecycle_envs = Katello::KTEnvironment.where(:name => ENV['LIFECYCLE_ENVIRONMENT']) if ENV['LIFECYCLE_ENVIRONMENT']
    content_views = Katello::ContentView.where(:name => ENV['CONTENT_VIEW']) if ENV['CONTENT_VIEW']

    repos = ::Katello::ContentViewPuppetEnvironment
    repos = repos.in_environment(lifecycle_envs) if lifecycle_envs
    repos = repos.in_content_view(content_views) if content_views
    repos
  end

  def repo_exists?(repo)
    Katello.pulp_server.extensions.repository.retrieve(repo.pulp_id)
    true
  rescue RestClient::ResourceNotFound
    false
  end

  def handle_missing_repo(repo)
    commit = ENV['COMMIT'] == 'true'
    puts "Repository #{repo.id} Missing"
    if repo.content_view.default?
      puts "Recreating #{repo.id}"
      ForemanTasks.sync_task(::Actions::Katello::Repository::Create, repo) if commit
    else
      puts "Deleting #{repo.id}"
      ForemanTasks.sync_task(::Actions::Katello::Repository::Destroy, repo, :planned_destroy => true) if commit
    end
  end

  def handle_missing_puppet_env(puppet_env)
    puts "Content View Puppet Environment #{puppet_env.id} Missing, Creating."
    ForemanTasks.sync_task(::Actions::Katello::ContentViewPuppetEnvironment::Create, puppet_env) if ENV['COMMIT'] == 'true'
  end
end
