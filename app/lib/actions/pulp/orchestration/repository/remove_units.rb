module Actions
  module Pulp
    module Orchestration
      module Repository
        class RemoveUnits < Pulp::Abstract
          def plan(_repository, _smart_proxy, options)
            sequence do
              plan_action(Actions::Repository::RemoveUnits, options)
            end
          end
        end
      end
    end
  end
end
