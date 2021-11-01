# rubocop:disable Metrics/MethodLength
module Actions
  module Pulp3
    module Orchestration
      module Repository
        class ImportUpload < Pulp3::Abstract
          # rubocop:disable Metrics/AbcSize
          def plan(repository, smart_proxy, args)
            file = {:filename => args.dig(:unit_key, :name), :sha256 => args.dig(:unit_key, :checksum) }
            content_unit_href = args.dig(:unit_key, :content_unit_id)
            docker_tag = (args.dig(:unit_type_id) == "docker_tag")
            unit_type_id = args.dig(:unit_type_id)

            Rails.logger.debug("Pulp3::Orchestration::ImportUpload plan args #{args}")

            sequence do
              if content_unit_href
                duplicate_sha_path_content_list = ::Katello::Pulp3::PulpContentUnit.find_duplicate_unit(repository, args.dig(:unit_type_id), file, file[:sha256])
                duplicate_content_href = duplicate_sha_path_content_list&.results&.first&.pulp_href

                if duplicate_content_href
                  plan_self(:commit_output => [], :content_unit_href => duplicate_content_href)
                  action_output = plan_action(Pulp3::Repository::ImportUpload, duplicate_content_href, repository, smart_proxy).output
                  plan_action(Pulp3::Repository::SaveVersion, repository, tasks: action_output[:pulp_tasks]).output
                else
                  duplicate_sha_artifact_list = ::Katello::Pulp3::Api::Core.new(smart_proxy).artifacts_api.list("sha256": file[:sha256])
                  duplicate_sha_artifact_href = duplicate_sha_artifact_list&.results&.first&.pulp_href
                  if duplicate_sha_artifact_href
                    artifact_output = plan_action(Pulp3::Repository::SaveArtifact,
                                                         file, repository, smart_proxy,
                                                         nil, args.dig(:unit_type_id),
                                                         artifact_href: duplicate_sha_artifact_href).output
                    content_unit_href = artifact_output[:pulp_tasks]
                    plan_self(:commit_output => nil, :artifact_output => artifact_output[:pulp_tasks])
                    action_output = plan_action(Pulp3::Repository::ImportUpload, content_unit_href, repository, smart_proxy).output
                    plan_action(Pulp3::Repository::SaveVersion, repository, tasks: action_output[:pulp_tasks]).output
                  end
                end
              elsif docker_tag
                tag_manifest_output = plan_action(Pulp3::Repository::UploadTag,
                            repository,
                            smart_proxy,
                            args).output
                plan_self(:commit_output => tag_manifest_output[:pulp_tasks])
                plan_action(Pulp3::Repository::SaveVersion, repository, {force_fetch_version: true, tasks: tag_manifest_output[:pulp_tasks]})
              else
                commit_output = plan_action(Pulp3::Repository::CommitUpload,
                                            repository,
                                            smart_proxy,
                                            "/pulp/api/v3/uploads/" + args.dig(:upload_id) + "/",
                                            args.dig(:unit_key, :checksum)).output
                           
                if unit_type_id != 'ostree_ref'
                  artifact_output = plan_action(Pulp3::Repository::SaveArtifact,
                                                file,
                                                repository,
                                                smart_proxy,
                                                commit_output[:pulp_tasks],
                                                args.dig(:unit_type_id)).output
                  content_unit_href = artifact_output&.[](:pulp_tasks)
                end

                plan_self(:commit_output => commit_output[:pulp_tasks], :artifact_output => artifact_output&.(:pulp_tasks))
                import_args = {}
                artifact_href = commit_output[:artifact_href]

                if unit_type_id == 'ostree_ref'
                  import_args = {
                    unit_type_id: unit_type_id,
                    artifact_href: artifact_href,
                    ref: args.dig(:ostree_ref),
                    parent_commit: args.dig(:ostree_parent_commit),
                    repository_name: args.dig(:ostree_repository_name)
                  }
                end

                action_output = plan_action(Pulp3::Repository::ImportUpload, content_unit_href, repository, smart_proxy, import_args).output
                plan_action(Pulp3::Repository::SaveVersion, repository, tasks: action_output[:pulp_tasks]).output
              end
            end
          end

          def run
            output[:pulp_tasks] = input[:commit_output]
            if input[:content_unit_href]
              output[:content_unit_href] = input[:content_unit_href]
            elsif input[:artifact_output]
              output[:content_unit_href] = input[:artifact_output].last[:created_resources].first
            else
              output[:content_unit_href] = nil
            end
          end
        end
      end
    end
  end
end
