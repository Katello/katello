module Actions
  module Pulp3
    module Orchestration
      module Repository
        class ImportUpload < Pulp3::AbstractAsyncTask
          def plan(repository, smart_proxy, args)
            file = {:filename => args.dig(:unit_key, :name)}
            content_unit_href = args.dig(:unit_key, :content_unit_id)
            sequence do
              if !content_unit_href
                action_output = plan_self(:repository_id => repository.id, :smart_proxy_id => smart_proxy.id, :upload_href => "/pulp/api/v3/uploads/" + args.dig(:upload_id) + "/", :sha256 => args.dig(:unit_key, :checksum)).output
                artifact_action_output = plan_action(Pulp3::Repository::SaveArtifact, file, repository, smart_proxy, action_output[:pulp_tasks], args.dig(:unit_type_id)).output
                content_unit_href = artifact_action_output[:pulp_tasks]
              else
                plan_self(:skip => true)
              end
              action_output = plan_action(Pulp3::Repository::ImportUpload, content_unit_href, repository, smart_proxy).output
              plan_action(Pulp3::Repository::SaveVersion, repository, tasks: action_output[:pulp_tasks]).output
            end
          end

          def invoke_external_task
            if input[:skip]
              output[:pulp_tasks] = nil
            else
              repo = ::Katello::Repository.find(input[:repository_id])
              repo_backend_service = repo.backend_service(smart_proxy)
              uploads_api = repo_backend_service.core_api.uploads_api
              output[:pulp_tasks] = [uploads_api.commit(input[:upload_href], sha256: input[:sha256])]
            end
          end
        end
      end
    end
  end
end
