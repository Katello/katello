module Actions
  module Pulp3
    module CapsuleContent
      class CreateVersion < Pulp3::AbstractAsyncTask
        def plan(repository, smart_proxy, options = {})
          sequence do
            action = plan_self(:repository_id => repository.id, :smart_proxy_id => smart_proxy.id)
          end
        end

        def invoke_external_task
          repo = ::Katello::Repository.find(input[:repository_id])
          output[:response] = repo.backend_service(smart_proxy).create_mirror_version
        end
      end
    end
  end
end
