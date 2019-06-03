module Actions
  module Pulp3
    module Repository
      class CopyVersion < Pulp3::AbstractAsyncTask
        def plan(source_repository, smart_proxy, target_repository)
          plan_self(:source_repository_id => source_repository.id,
                    :target_repository_id => target_repository.id,
                    :smart_proxy_id => smart_proxy.id)
        end

        def invoke_external_task
          source = ::Katello::Repository.find(input[:source_repository_id])
          target = ::Katello::Repository.find(input[:target_repository_id] || input[:target_repository])
          output[:pulp_tasks] = target.backend_service(smart_proxy).copy_version(source)
        end
      end
    end
  end
end
