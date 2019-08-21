module Actions
  module Pulp3
    module Orchestration
      module Repository
        class ImportUpload < Pulp3::AbstractAsyncTask
          def plan(repository, smart_proxy, args)
            file = {:filename => args.dig(:unit_key, :name)}
            sequence do
              action_output = plan_self(:repository_id => repository.id, :smart_proxy_id => smart_proxy.id, :upload_href => "/pulp/api/v3/uploads/" + args.dig(:upload_id) + "/", :sha256 => args.dig(:unit_key, :checksum)).output
              artifact_action_output = plan_action(Pulp3::Repository::SaveArtifact, file, repository, action_output[:pulp_tasks], args.dig(:unit_type_id)).output
              action_output = plan_action(Pulp3::Repository::ImportUpload, artifact_action_output[:content_unit_href], repository, smart_proxy).output
              plan_action(Pulp3::Repository::SaveVersion, repository, action_output[:pulp_tasks]).output

            end
          end

          def invoke_external_task
            repo = ::Katello::Repository.find(input[:repository_id])
            repo_backend_service = repo.backend_service(smart_proxy)
            uploads_api = repo_backend_service.uploads_api
            output[:pulp_tasks] = [uploads_api.commit(input[:upload_href], sha256: input[:sha256])]
          end
        end
      end
    end
  end
end
