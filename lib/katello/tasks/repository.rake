namespace :katello do
  task :disable_dynflow do
    ForemanTasks.dynflow.config.remote = true
  end

  def commit?
    ENV['COMMIT'] == 'true' || ENV['FOREMAN_UPGRADE'] == '1'
  end

  desc "Check for repositories that have not been published since their last sync, and republish if they have."
  task :publish_unpublished_repositories => ["environment", "disable_dynflow", "check_ping"] do
    needing_publish = []
    Organization.find_each do |org|
      if org.default_content_view && !org.default_content_view.versions.empty?
        org.default_content_view.versions.first.repositories.joins(:root)
          .where.not(katello_root_repositories: { url: nil }).find_each do |repo|
          begin
            if repo.needs_metadata_publish?
              Rails.logger.error("Repository metadata for #{repo.name} (#{repo.id}) is out of date, regenerating.")
              needing_publish << repo.id
            end
          rescue => e
            puts "Failed to check repository #{repo.id}: #{e}"
          end
        end
      end
    end
    if needing_publish.any?
      ForemanTasks.async_task(::Actions::Katello::Repository::BulkMetadataGenerate, Katello::Repository.where(:id => needing_publish))
    end
  end

  desc "Regnerate metadata for all repositories. Specify CONTENT_VIEW=name and LIFECYCLE_ENVIRONMENT=name to narrow repositories."
  task :regenerate_repo_metadata => ["environment", "disable_dynflow", "check_ping"] do
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
  task :refresh_pulp_repo_details => ["environment", "disable_dynflow", "check_ping"] do
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
  end

  desc "Correct missing pulp repositories for puppet environments. Specify CONTENT_VIEW=name and LIFECYCLE_ENVIRONMENT=name to narrow repositories.  COMMIT=true to perform operation."
  task :correct_puppet_environments => ["environment", "check_ping"] do
    puts "All operations will be skipped.  Re-run with COMMIT=true to perform corrections." unless commit?

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
    puts "Repository #{repo.id} Missing"
    if repo.content_view.default?
      puts "Recreating #{repo.id}"
      ForemanTasks.sync_task(::Actions::Katello::Repository::Create, repo) if commit?
    else
      puts "Deleting #{repo.id}"
      ForemanTasks.sync_task(::Actions::Katello::Repository::Destroy, repo) if commit?
    end
  end

  def handle_missing_puppet_env(puppet_env)
    puts "Content View Puppet Environment #{puppet_env.id} Missing, Creating."
    ForemanTasks.sync_task(::Actions::Katello::ContentViewPuppetEnvironment::Create, puppet_env) if commit?
  end
end
