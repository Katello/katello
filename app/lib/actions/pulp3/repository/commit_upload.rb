module Actions
  module Pulp3
    module Repository
      class CommitUpload < Pulp3::AbstractAsyncTask
        def plan(repository, smart_proxy, upload_href, sha256)
          plan_self(:repository_id => repository.id, :smart_proxy_id => smart_proxy.id, :upload_href => upload_href, :sha256 => sha256)
        end

        def invoke_external_task
          repo = ::Katello::Repository.find(input[:repository_id])
          repo_backend_service = repo.backend_service(smart_proxy)
          uploads_api = repo_backend_service.core_api.uploads_api
          output[:pulp_tasks] = [uploads_api.commit(input[:upload_href], sha256: input[:sha256])]
        end
      end
    end
  end
end
