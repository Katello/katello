module Actions
  module Pulp3
    module Repository
      class UpdateRemote < Pulp3::AbstractAsyncTask
        def plan(repository, smart_proxy)
          if repository.root.url
            repository.backend_service(smart_proxy).create_test_remote if smart_proxy.pulp_primary?
            plan_self(:repository_id => repository.id, :smart_proxy_id => smart_proxy.id)
          end
        end

        def invoke_external_task
          repo = ::Katello::Repository.find(input[:repository_id])
          repo.backend_service(smart_proxy).update_remote
        end
      end
    end
  end
end
