namespace :katello do
  desc 'Refresh all alternate content sources'
  task :refresh_alternate_content_sources => ["dynflow:client"] do
    User.current = User.anonymous_admin
    ::ForemanTasks.async_task(::Actions::BulkAction,
                              ::Actions::Katello::AlternateContentSource::Refresh,
                              ::Katello::AlternateContentSource.all)
    puts _("Alternate content source refreshing started in the background.")
  end
end
