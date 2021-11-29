module Actions
  module Pulp3
    module Orchestration
      module Repository
        #Used for a different type of uploading where you are importing an entire repository, not a single content unit
        # This workflow involves never actually creating a content unit directly, but instead importing the artifact directly into the repository
        class ImportRepositoryUpload < Pulp3::Abstract
          def plan(repository, smart_proxy, args)
            file = {:filename => args.dig(:unit_key, :name), :sha256 => args.dig(:unit_key, :checksum) }
            sequence do
              upload_href = "/pulp/api/v3/uploads/#{args.dig(:upload_id)}/" if args.dig(:upload_id) && args.dig(:upload_id) != 'duplicate'
              commit_output = plan_action(Pulp3::Repository::CommitUpload,
                                          repository,
                                          smart_proxy,
                                          upload_href,
                                          args.dig(:unit_key, :checksum)).output

              artifact_output = plan_action(Pulp3::Repository::SaveArtifact,
                                            file,
                                            repository,
                                            smart_proxy,
                                            commit_output[:pulp_tasks],
                                            args.dig(:unit_type_id), args).output
              plan_self(:artifact_output => artifact_output)
              plan_action(Pulp3::Repository::SaveVersion, repository, tasks: artifact_output[:pulp_tasks])
            end
          end

          def run
            output[:content_unit_href] = input[:artifact_output][:content_unit_href] || input[:artifact_output][:pulp_tasks].last[:created_resources].first
          end
        end
      end
    end
  end
end
