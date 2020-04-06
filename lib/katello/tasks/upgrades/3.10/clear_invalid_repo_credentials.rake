# Before 3.8, you could successfully edit only the username, or only the
# password, but since we added a validation now those old repos are now
# invalid.  This finds those repos and clears their credentials.

namespace :katello do
  namespace :upgrades do
    namespace '3.10' do
      desc "Clear invalid credentials for repositories"
      task :clear_invalid_repo_credentials => %w(environment) do
        User.current = User.anonymous_admin

        # Where one, but not both, is set
        root_repos = Katello::RootRepository.where('(upstream_username IS NULL AND upstream_password is NOT NULL) OR (upstream_username IS NOT NULL AND upstream_password is NULL)')

        root_repos.each do |root_repo|
          puts "Clearing invalid credentials for #{root_repo.label} (#{root_repo.id})"
          root_repo.update(upstream_username: nil, upstream_password: nil)

          root_repo.repositories.each do |repo|
            puts "Refreshing repository #{repo.label} (#{repo.id})"
            ForemanTasks.sync_task(::Actions::Pulp::Repository::Refresh, repo)
          end
        end
      end
    end
  end
end
