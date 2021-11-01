module Actions
  module Pulp3
    module Orchestration
      module Repository
        class UploadContent < Pulp3::Abstract
          include Actions::Helpers::OutputPropagator

          # rubocop:disable Metrics/MethodLength
          # rubocop:disable Metrics/CyclomaticComplexity
          def plan(repository, smart_proxy, file, unit_type_id, options)
            sequence do
              checksum = Digest::SHA256.hexdigest(File.read(file[:path]))
              duplicate_sha_path_content_list = ::Katello::Pulp3::PulpContentUnit.find_duplicate_unit(repository, unit_type_id, file, checksum)
              duplicate_content_href = duplicate_sha_path_content_list&.results&.first&.pulp_href

              unless duplicate_content_href
                duplicate_sha_artifact_list = ::Katello::Pulp3::Api::Core.new(smart_proxy).artifacts_api.list(
                  'sha256': Digest::SHA256.hexdigest(File.read(file[:path])))
                
                duplicate_sha_artifact_href = duplicate_sha_artifact_list&.results&.first&.pulp_href
                if duplicate_sha_artifact_href
                  if unit_type_id != "ostree_ref"
                    artifact_action_output = plan_action(Pulp3::Repository::SaveArtifact, file, repository, smart_proxy, nil, unit_type_id, artifact_href: duplicate_sha_artifact_href).output
                  end
                else
                  upload_action_output = plan_action(Pulp3::Repository::UploadFile, repository, smart_proxy, file[:path]).output
                  artifact_href = upload_action_output[:artifact_href]
                  if unit_type_id != "ostree_ref"
                    artifact_action_output = plan_action(Pulp3::Repository::SaveArtifact, file, repository, smart_proxy, upload_action_output[:pulp_tasks], unit_type_id).output
                  end
                end
                content_href = artifact_action_output&.[](:pulp_tasks)
              end
              artifact_href ||= duplicate_sha_artifact_href
              content_href ||= duplicate_content_href
              import_args = {}

              if unit_type_id == 'ostree_ref'
                import_args = {
                  unit_type_id: unit_type_id,
                  artifact_href: artifact_href,
                  ref: options[:ostree_ref],
                  parent_commit: options[:ostree_parent_commit],
                  repository_name: options[:ostree_repository_name]
                }
              end

              action_output = plan_action(Pulp3::Repository::ImportUpload, content_href, repository, smart_proxy,
                import_args).output
              plan_action(Pulp3::Repository::SaveVersion, repository, tasks: action_output[:pulp_tasks]).output
              plan_self(:subaction_output => action_output)
            end
            # rubocop:enable Metrics/MethodLength
            # rubocop:enable Metrics/CyclomaticComplexity
          end
        end
      end
    end
  end
end
