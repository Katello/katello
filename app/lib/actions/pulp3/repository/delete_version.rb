module Actions
  module Pulp3
    module Repository
      class DeleteVersion < Pulp3::AbstractAsyncTask
        def plan(repository, smart_proxy)
          #A version from library might be reused in a composite, or could have been copied
          # from a library repository, so only delete the version if its the last
          if ::Katello::Repository.where(:version_href => repository.version_href).count == 1
            plan_self(:repository_id => repository.id, :smart_proxy_id => smart_proxy.id)
          end
        end

        def invoke_external_task
          repo = ::Katello::Repository.find(input[:repository_id])
          output[:response] = repo.backend_service(smart_proxy).delete_version
        end
      end
    end
  end
end
