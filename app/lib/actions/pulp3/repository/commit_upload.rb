module Actions
  module Pulp3
    module Repository
      #Creates an artifacts
      class CommitUpload < Pulp3::AbstractAsyncTask
        def plan(repository, smart_proxy, upload_href, sha256)
          plan_self(:repository_id => repository.id, :smart_proxy_id => smart_proxy.id, :upload_href => upload_href, :sha256 => sha256)
        end

        def invoke_external_task
          repo = ::Katello::Repository.find(input[:repository_id])
          repo_backend_service = repo.backend_service(smart_proxy)
          uploads_api = repo_backend_service.core_api.uploads_api

          duplicate_sha_artifact_list = ::Katello::Pulp3::Api::Core.new(smart_proxy).artifacts_api.list("sha256": input[:sha256])
          duplicate_sha_artifact_href = duplicate_sha_artifact_list&.results&.first&.pulp_href
          if duplicate_sha_artifact_href
            uploads_api.delete(input[:upload_href]) if input[:upload_href]
            output[:artifact_href] = duplicate_sha_artifact_href
            output[:pulp_tasks] = nil
          else
            output[:artifact_href] = nil
            upload_commit = repo_backend_service.core_api.upload_commit_class.new(sha256: input[:sha256])
            output[:pulp_tasks] = [uploads_api.commit(input[:upload_href], upload_commit)]
          end
        end

        def check_for_errors
          combined_tasks.each do |task|
            if unique_error task.error
              warn _("Duplicate artifact detected")
            else
              super
            end
          end
        end

        def unique_error(message)
          message&.include?("code='unique'")
        end
      end
    end
  end
end
