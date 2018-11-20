# Before 3.8, you could successfully edit only the username, or only the
# password, but since we added a validation now those old repos are now
# invalid, breaking upgrades.  This finds those repos and clears their
# credentials.

namespace :katello do
  namespace :upgrades do
    namespace '3.8' do
      desc "Clear invalid credentials for repositories"
      task :annul_invalid_repo_credentials => %w(environment) do
        User.current = User.anonymous_admin

        # Where one, but not both, is set
        repos = Katello::Repository.where('(upstream_username IS NULL AND upstream_password is NOT NULL) OR (upstream_username IS NOT NULL AND upstream_password is NULL)')

        repos.each do |repo|
          puts "Clearing invalid credentials for #{repo.label} (#{repo.id})"
          repo.update_attributes(upstream_username: nil, upstream_password: nil)
          ForemanTasks.sync_task(::Actions::Pulp::Repository::Refresh, repo)
        end
      end
    end
  end
end
