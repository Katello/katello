module Actions
  module Pulp3
    module Orchestration
      module Repository
        class RefreshIfNeeded < Pulp3::AbstractAsyncTask
          def plan(repository, smart_proxy, _options = {})
            plan_self(repository_id: repository.id, smart_proxy_id: smart_proxy.id)
          end

          def invoke_external_task
            repo = ::Katello::Repository.find(input[:repository_id])
            repo.backend_service(smart_proxy).refresh_if_needed
          end
        end
      end
    end
  end
end
