namespace :katello do
  desc 'Refresh all repositories in all smart proxies and main server'
  task :refresh_repos => ["environment", "dynflow:client"] do
    User.current = User.anonymous_api_admin
    ::ForemanTasks.async_task(::Actions::BulkAction, ::Actions::Pulp3::Orchestration::Repository::RefreshRepos, SmartProxy.all)
    puts _("Repos are being refreshed in the background.")
  end
end
