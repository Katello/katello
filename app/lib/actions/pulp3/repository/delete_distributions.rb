module Actions
  module Pulp3
    module Repository
      class DeleteDistributions < Pulp3::AbstractAsyncTask
        def plan(repository, smart_proxy)
          plan_self(:repository_id => repository.id, :smart_proxy_id => smart_proxy.id)
        end

        def invoke_external_task
          repo = ::Katello::Repository.find(input[:repository_id])
          repo.backend_service(smart_proxy).delete_distributions
        end
      end
    end
  end
end
