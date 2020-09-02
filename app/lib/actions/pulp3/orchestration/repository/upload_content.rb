module Actions
  module Pulp3
    module Orchestration
      module Repository
        class UploadContent < Pulp3::Abstract
          include Actions::Helpers::OutputPropagator
          def plan(repository, smart_proxy, file, unit_type_id)
            sequence do
              content_backend_service = SmartProxy.pulp_primary.content_service(unit_type_id)
              content_list = content_backend_service.content_api.list("sha256": Digest::SHA256.hexdigest(File.read(file[:path])))
              content_href = content_list&.results&.first&.pulp_href

              unless content_href
                upload_action_output = plan_action(Pulp3::Repository::UploadFile, repository, smart_proxy, file[:path]).output
                artifact_action_output = plan_action(Pulp3::Repository::SaveArtifact, file, repository, smart_proxy, upload_action_output[:pulp_tasks], unit_type_id).output
                content_href = artifact_action_output[:pulp_tasks]
              end
              action_output = plan_action(Pulp3::Repository::ImportUpload, content_href, repository, smart_proxy).output
              plan_action(Pulp3::Repository::SaveVersion, repository, tasks: action_output[:pulp_tasks]).output
              plan_self(:subaction_output => action_output)
            end
          end
        end
      end
    end
  end
end
