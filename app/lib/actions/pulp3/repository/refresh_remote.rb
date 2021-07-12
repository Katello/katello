module Actions
  module Pulp3
    module Repository
      class RefreshRemote < Pulp3::AbstractAsyncTask
        def plan(repository, smart_proxy)
          plan_self(repository_id: repository.id, smart_proxy_id: smart_proxy.id)
        end

        def invoke_external_task
          repo = ::Katello::Repository.find(input[:repository_id])
          backend = repo.backend_service(smart_proxy)
          backend.update_remote
        end
      end
    end
  end
end
