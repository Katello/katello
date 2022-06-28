namespace :katello do
  desc 'Refresh all alternate content sources'
  task :refresh_alternate_content_sources => ["dynflow:client"] do
    User.current = User.anonymous_admin
    alternate_content_sources = ::Katello::AlternateContentSource.all
    if alternate_content_sources.present?
      ::ForemanTasks.async_task(::Actions::BulkAction,
                                ::Actions::Katello::AlternateContentSource::Refresh,
                                alternate_content_sources)
      puts _("Alternate content source refreshing started in the background.")
    else
      puts _("No alternate content sources to refresh.")
    end
  end
end
