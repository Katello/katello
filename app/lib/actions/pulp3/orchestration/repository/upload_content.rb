module Actions
  module Pulp3
    module Orchestration
      module Repository
        class UploadContent < Pulp3::Abstract
          def plan(repository, smart_proxy, file, unit_type_id)
            sequence do
              content_backend_service = SmartProxy.pulp_master.content_service(unit_type_id)
              content_list = content_backend_service.content_api.list("digest": Digest::SHA256.hexdigest(File.read(file[:path])))
              if content_list.results.empty?
                upload_action_output = plan_action(Pulp3::Repository::UploadFile, repository, smart_proxy, file[:path]).output
                artifact_action_output = plan_action(Pulp3::Repository::SaveArtifact, file, repository, smart_proxy, upload_action_output[:pulp_tasks], unit_type_id).output
                content_unit_href = artifact_action_output[:pulp_tasks]
              else
                content_unit_href = content_list.results.first.pulp_href
              end
              action_output = plan_action(Pulp3::Repository::ImportUpload, content_unit_href, repository, smart_proxy).output
              plan_action(Pulp3::Repository::SaveVersion, repository, tasks: action_output[:pulp_tasks]).output
            end
          end
        end
      end
    end
  end
end
