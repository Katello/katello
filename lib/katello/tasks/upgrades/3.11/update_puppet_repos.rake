namespace :katello do
  namespace :upgrades do
    namespace '3.11' do
      desc "update puppet repos to regenerate pulp configuration"
      task :update_puppet_repos => %w(environment) do
        User.current = User.anonymous_admin
        Katello::Repository.puppet_type.each do |repo|
          begin
            puts "Refreshing repository #{repo.label} (#{repo.id})"
            install_dist = repo.backend_service(SmartProxy.pulp_master).backend_data['distributors'].find { |dist| dist['distributor_type_id'] == 'puppet_install_distributor' }
            if install_dist
              SmartProxy.pulp_master.pulp_api.resources.repository.delete_distributor(repo.pulp_id, install_dist['id'])
            end
            ForemanTasks.sync_task(::Actions::Pulp::Repository::Refresh, repo)
          rescue RestClient::ResourceNotFound
            Rails.logger.warn("Recieved 404 on repository: #{repo.id} - #{repo.name}")
            next
          end
        end
      end
    end
  end
end
