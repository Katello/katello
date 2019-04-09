module Actions
  module Pulp3
    module Orchestration
      module Repository
        class Sync < Pulp3::Abstract
          include Helpers::Presenter
          def plan(repository, smart_proxy, options)
            sequence do
              action_output = plan_action(Actions::Pulp3::Repository::Sync, options).output
              plan_action(Pulp3::Repository::SaveVersion, repository, action_output[:pulp_tasks])
              plan_action(Pulp3::Orchestration::Repository::GenerateMetadata, repository, SmartProxy.pulp_master, {:force => true})
              plan_self(:output => action_output)
            end
          end

          def run
            input[:output].each do |key, value|
              output[key] = value
            end
          end

          def presenter
            Helpers::Presenter::Delegated.new(self, planned_actions(Pulp3::Repository::Sync))
          end
        end
      end
    end
  end
end
