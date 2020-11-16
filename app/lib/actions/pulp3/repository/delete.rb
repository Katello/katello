module Actions
  module Pulp3
    module Repository
      class Delete < Pulp3::AbstractAsyncTask
        def plan(repository_id, smart_proxy)
          plan_self(:repository_id => repository_id, :smart_proxy_id => smart_proxy.id)
        end

        def invoke_external_task
          repo = ::Katello::Repository.find(input[:repository_id])
          output[:response] = repo.backend_service(smart_proxy).delete_repository
        end
      end
    end
  end
end
