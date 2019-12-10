module Actions
  module Pulp3
    module Orchestration
      module Repository
        class Sync < Pulp3::Abstract
          include Actions::Helpers::OutputPropagator
          def plan(repository, smart_proxy, options)
            sequence do
              action_output = plan_action(Actions::Pulp3::Repository::Sync, repository, smart_proxy, options).output
              version_output = plan_action(Pulp3::Repository::SaveVersion, repository, tasks: action_output[:pulp_tasks]).output
              plan_action(Pulp3::Orchestration::Repository::GenerateMetadata, repository, smart_proxy, :contents_changed => version_output[:contents_changed])
              plan_self(:subaction_output => version_output)
            end
          end
        end
      end
    end
  end
end
