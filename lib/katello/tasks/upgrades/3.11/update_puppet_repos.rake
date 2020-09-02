namespace :katello do
  namespace :upgrades do
    namespace '3.11' do
      def wait_on_task(task, time = 0.1)
        task = SmartProxy.pulp_primary.pulp_api.resources.task.poll(task['task_id'])
        return if Actions::Pulp::AbstractAsyncTask::FINISHED_STATES.include?(task['state'])
        sleep time
        wait_on_task(task, time + 0.2)
      end

      desc "update puppet repos to regenerate pulp configuration"
      task :update_puppet_repos => %w(environment) do
        User.current = User.anonymous_admin
        Katello::Repository.puppet_type.each do |repo|
          puts "Refreshing repository #{repo.label} (#{repo.id})"
          install_dist = repo.backend_service(SmartProxy.pulp_primary).backend_data['distributors'].find { |dist| dist['distributor_type_id'] == 'puppet_install_distributor' }
          if install_dist
            response = SmartProxy.pulp_primary.pulp_api.resources.repository.delete_distributor(repo.pulp_id, install_dist['id'])
            wait_on_task('task_id' => response['spawned_tasks'][0]['task_id'])
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
