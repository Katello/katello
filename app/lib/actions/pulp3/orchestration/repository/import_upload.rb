module Actions
  module Pulp3
    module Orchestration
      module Repository
        class ImportUpload < Pulp3::Abstract
          def plan(repository, smart_proxy, args)
            file = {:filename => args.dig(:unit_key, :name)}
            content_unit_href = args.dig(:unit_key, :content_unit_id)
            sequence do
              if content_unit_href
                plan_self(:commit_output => [], :content_unit_href => content_unit_href)
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
                                              args.dig(:unit_type_id)).output
                content_unit_href = artifact_output[:pulp_tasks]
                plan_self(:commit_output => commit_output[:pulp_tasks], :artifact_output => artifact_output[:pulp_tasks])
              end
              action_output = plan_action(Pulp3::Repository::ImportUpload, content_unit_href, repository, smart_proxy).output
              plan_action(Pulp3::Repository::SaveVersion, repository, tasks: action_output[:pulp_tasks]).output
            end
          end

          def run
            output[:pulp_tasks] = input[:commit_output]
            if input[:content_unit_href]
              output[:content_unit_href] = input[:content_unit_href]
            else
              output[:content_unit_href] = input[:artifact_output].last[:created_resources].first
            end
          end
        end
      end
    end
  end
end
