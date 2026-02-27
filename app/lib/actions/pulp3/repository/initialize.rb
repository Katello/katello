module Actions
  module Pulp3
    module Repository
      class Initialize < Pulp3::AbstractAsyncTask
        def plan(repository, smart_proxy, options = {})
          plan_self(repository_id: repository.id,
                    smart_proxy_id: smart_proxy.id,
                    repository_details: options[:repository_details])
        end

        def invoke_external_task
          if input[:repository_details]
            repository = ::Katello::Repository.find(input[:repository_id])
            output[:pulp_tasks] = repository.backend_service(smart_proxy).initialize_empty
          end
        end
      end
    end
  end
end
