namespace :katello do
  desc 'Refresh all repositories on content smart proxies'
  task :refresh_repos => ["environment", "dynflow:client"] do
    User.current = User.anonymous_api_admin
    ::ForemanTasks.async_task(::Actions::BulkAction, ::Actions::Pulp3::Orchestration::Repository::RefreshRepos, SmartProxy.with_content)
    puts _("Repos are being refreshed in the background.")
  end
end
