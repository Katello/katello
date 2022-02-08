module Actions
  module Pulp3
    module Repository
      class CopyContent < Pulp3::AbstractAsyncTask
        def plan(source_repository, smart_proxy, target_repository, options)
          plan_self(options.merge(:source_repository_id => source_repository.id,
                                  :target_repository_id => target_repository.id,
                                  :smart_proxy_id => smart_proxy.id))
        end

        def invoke_external_task
          source = ::Katello::Repository.find(input[:source_repository_id])
          target = ::Katello::Repository.find(input[:target_repository_id] || input[:target_repository])
          service = target.backend_service(smart_proxy)
          output[:pulp_tasks] = if input[:copy_all]
                                  service.copy_all(source, input)
                                else
                                  service.copy_content_for_source(source, input)
                                end
        end
      end
    end
  end
end
