namespace :katello do
  namespace :upgrades do
    namespace '4.8' do
      desc "Regenerates metadata for library repositories that were imported"
      task :regenerate_imported_repository_metadata => ["dynflow:client", "environment"] do
        User.current = User.anonymous_admin #set a user for orchestration
        versions = Katello::ContentViewVersionImportHistory.all.map(&:content_view_version)
        repos = versions.map do |ver|
          rps = if ver.default?
                  ver.repositories
                else
                  ver.archived_repos
                end
          rps.exportable
            .map(&:library_instance_or_self)
            .select(&:using_mirrored_metadata?)
        end
        repos.flatten!
        repos.uniq!

        if repos.any?
          task = ForemanTasks.async_task(::Actions::BulkAction,
                                         ::Actions::Katello::Repository::MetadataGenerate,
                                         repos,
                                         force_publication: true)
          puts "Refreshing #{repos.count} repositories. You can monitor these on task id #{task.id}\n"
        else
          puts "No repositories found for regeneration."
        end
      end
    end
  end
end
