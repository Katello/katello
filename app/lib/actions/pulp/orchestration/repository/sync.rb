module Actions
  module Pulp
    module Orchestration
      module Repository
        class Sync < Pulp::Abstract
          include Helpers::Presenter
          def plan(repository, smart_proxy, options)
            sequence do
              action_output = plan_action(Actions::Pulp::Repository::Sync, options).output
              plan_self(:output => action_output)
            end
          end

          def run
            input[:output].each do |key, value|
              output[key] = value
            end
          end

          def presenter
            Helpers::Presenter::Delegated.new(self, planned_actions(Pulp::Repository::Sync))
          end
        end
      end
    end
  end
end
