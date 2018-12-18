namespace :katello do
  namespace :upgrades do
    namespace '3.11' do
      desc "update puppet repos to regenerate pulp configuration"
      task :update_puppet_repos => %w(environment) do
        User.current = User.anonymous_admin
        Katello::Repository.puppet_type.each do |repo|
          puts "Refreshing repository #{repo.label} (#{repo.id})"
          ForemanTasks.sync_task(::Actions::Pulp::Repository::Refresh, repo)
        end
      end
    end
  end
end
