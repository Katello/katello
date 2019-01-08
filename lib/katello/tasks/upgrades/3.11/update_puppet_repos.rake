namespace :katello do
  namespace :upgrades do
    namespace '3.11' do
      desc "update puppet repos to regenerate pulp configuration"
      task :update_puppet_repos => %w(environment) do
        User.current = User.anonymous_admin
        Katello::Repository.puppet_type.each do |repo|
          puts "Refreshing repository #{repo.label} (#{repo.id})"
          install_dist = repo.backend_service(SmartProxy.pulp_master).backend_data['distributors'].find { |dist| dist['distributor_type_id'] == 'puppet_install_distributor' }
          SmartProxy.pulp_master.pulp_api.resources.repository.delete_distributor(repo.pulp_id, install_dist['id'])
          ForemanTasks.sync_task(::Actions::Pulp::Repository::Refresh, repo)
        end
      end
    end
  end
end
