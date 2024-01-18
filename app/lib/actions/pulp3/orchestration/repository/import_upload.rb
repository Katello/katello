# rubocop:disable Metrics/MethodLength
module Actions
  module Pulp3
    module Orchestration
      module Repository
        class ImportUpload < Pulp3::Abstract
          def plan(repository, smart_proxy, args)
            file = {:filename => args.dig(:unit_key, :name), :sha256 => args.dig(:unit_key, :checksum) }
            content_unit_href = args.dig(:unit_key, :content_unit_id)
            docker_tag = (args.dig(:unit_type_id) == "docker_tag")

            sequence do
              if docker_tag
                tag_manifest_output = plan_action(Pulp3::Repository::UploadTag,
                                                  repository,
                                                  smart_proxy,
                                                  args).output
                plan_self(:commit_output => tag_manifest_output[:pulp_tasks])
                plan_action(Pulp3::Repository::SaveVersion, repository, force_fetch_version: true, tasks: tag_manifest_output[:pulp_tasks])
              else
                if content_unit_href
                  artifact_output = { :content_unit_href => content_unit_href }
                  commit_output = {}
                else
                  commit_output = plan_action(Pulp3::Repository::CommitUpload,
                                              repository,
                                              smart_proxy,
                                              "/pulp/api/v3/uploads/" + args.dig(:upload_id) + "/",
                                              args.dig(:unit_key, :checksum)).output

                  artifact_output = plan_action(Pulp3::Repository::SaveArtifact,
                                                file,
                                                repository,
                                                smart_proxy,
                                                commit_output[:pulp_tasks],
                                                args.dig(:unit_type_id), **args).output
                end

                plan_self(:commit_output => commit_output[:pulp_tasks], :artifact_output => artifact_output)
                import_output = plan_action(Pulp3::Repository::ImportUpload, artifact_output, repository, smart_proxy).output
                plan_action(Pulp3::Repository::SaveVersion, repository, tasks: import_output[:pulp_tasks])
              end
            end
          end

          def run
            output[:pulp_tasks] = input[:commit_output]
            if input[:content_unit_href]
              output[:content_unit_href] = input[:content_unit_href]
            elsif input[:artifact_output]
              output[:content_unit_href] = input[:artifact_output][:content_unit_href] || input[:artifact_output][:pulp_tasks].last[:created_resources].first
            else
              output[:content_unit_href] = nil
            end
          end
        end
      end
    end
  end
end
