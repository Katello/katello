module Actions
  module Pulp3
    module Repository
      class CreateVersion < Pulp3::AbstractAsyncTask
        def plan(repository, smart_proxy)
          sequence do
            action = plan_self(:repository_id => repository.id, :smart_proxy_id => smart_proxy.id)
            plan_action(SaveVersion, repository, action.output[:pulp_tasks])
          end
        end

        def invoke_external_task
          repo = ::Katello::Repository.find(input[:repository_id])
          output[:response] = repo.backend_service(smart_proxy).with_mirror_adapter.create_version
        end
      end
    end
  end
end
