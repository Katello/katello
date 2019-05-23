module Actions
  module Pulp3
    module Orchestration
      module Repository
        class RemoveUnits < Pulp3::Abstract
          def plan(repository, smart_proxy, options)
            sequence do
              plan_action(Actions::Pulp3::Repository::RemoveUnits, repository, smart_proxy, options)
            end
          end
        end
      end
    end
  end
end
