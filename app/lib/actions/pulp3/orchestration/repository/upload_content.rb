module Actions
  module Pulp3
    module Orchestration
      module Repository
        class UploadContent < Pulp3::Abstract
          include Actions::Helpers::OutputPropagator
          def plan(repository, smart_proxy, file, unit_type_id)
            file = upload_file_metadata(repository, file)
            sequence do
              if repository.deb?
                upload_action_output = plan_action(Pulp3::Repository::UploadFile, repository, smart_proxy, file).output
                artifact_action_output = plan_action(Pulp3::Repository::SaveArtifact, file, repository, smart_proxy, upload_action_output[:pulp_tasks], unit_type_id).output
              else
                checksum = file[:sha256] || Digest::SHA256.file(file[:path]).hexdigest
                duplicate_sha_path_content_list = ::Katello::Pulp3::PulpContentUnit.find_duplicate_unit(repository, unit_type_id, file, checksum)
                duplicate_content_href = duplicate_sha_path_content_list&.results&.first&.pulp_href

                unless duplicate_content_href
                  duplicate_sha_artifact_list = ::Katello::Pulp3::Api::Core.new(smart_proxy).artifacts_api.list("sha256": checksum)
                  duplicate_sha_artifact_href = duplicate_sha_artifact_list&.results&.first&.pulp_href
                  if duplicate_sha_artifact_href
                    artifact_action_output = plan_action(Pulp3::Repository::SaveArtifact, file, repository, smart_proxy, nil, unit_type_id, artifact_href: duplicate_sha_artifact_href).output
                  else
                    upload_action_output = plan_action(Pulp3::Repository::UploadFile, repository, smart_proxy, file).output
                    artifact_action_output = plan_action(Pulp3::Repository::SaveArtifact, file, repository, smart_proxy, upload_action_output[:pulp_tasks], unit_type_id).output
                  end
                end
                artifact_action_output ||= {:content_unit_href => duplicate_content_href}
              end

              action_output = plan_action(Pulp3::Repository::ImportUpload, artifact_action_output, repository, smart_proxy).output
              plan_action(Pulp3::Repository::SaveVersion, repository, tasks: action_output[:pulp_tasks]).output
              plan_self(:subaction_output => action_output)
            end
          end

          private

          def upload_file_metadata(repository, file)
            if ::Katello::UploadStaging.supported?
              staging = ::Katello::UploadStaging.resolve(file, repository.id, execution_plan_id)
              return staging.metadata if staging
            end
            return file unless file[:path]

            file.merge(sha256: Digest::SHA256.file(file[:path]).hexdigest)
          end
        end
      end
    end
  end
end
