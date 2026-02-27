module Actions
  module Pulp3
    module Repository
      class DebRemoveEmptyMetadata < Pulp3::AbstractAsyncTask
        def plan(repository, smart_proxy)
          if repository.deb? && repository.version_href.ends_with?("/1/")
            plan_self(repository_id: repository.id,
                      smart_proxy_id: smart_proxy.id)
          end
        end

        def invoke_external_task
          repository = ::Katello::Repository.find(input[:repository_id])
          output[:pulp_tasks] = repository.backend_service(smart_proxy).remove_empty_metadata
        end
      end
    end
  end
end
