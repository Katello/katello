module Actions
  module Pulp3
    module Orchestration
      module Repository
        class UploadContent < Pulp3::Abstract
          def plan(repository, smart_proxy, file, unit_type_id)
            sequence do
              upload_action_output = plan_action(Pulp3::Repository::UploadFile, repository, smart_proxy, file[:path]).output
              artifact_action_output = plan_action(Pulp3::Repository::SaveArtifact, file, repository, upload_action_output[:pulp_tasks], unit_type_id).output
              action_output = plan_action(Pulp3::Repository::ImportUpload, artifact_action_output[:content_unit_href], repository, smart_proxy).output
              plan_action(Pulp3::Repository::SaveVersion, repository, action_output[:pulp_tasks]).output
            end
          end
        end
      end
    end
  end
end
