module Actions
  module Pulp3
    module Orchestration
      module Repository
        class RemoveUnits < Pulp3::Abstract
          include Actions::Helpers::OutputPropagator

          def plan(repository, smart_proxy, options)
            sequence do
              action_output = plan_action(Actions::Pulp3::Repository::RemoveUnits, repository, smart_proxy, **options).output
              plan_action(Pulp3::Repository::SaveVersion, repository, tasks: action_output[:pulp_tasks])
            end
          end
        end
      end
    end
  end
end
