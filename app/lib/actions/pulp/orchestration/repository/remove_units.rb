module Actions
  module Pulp
    module Orchestration
      module Repository
        class RemoveUnits < Pulp::Abstract
          def plan(_repository, _smart_proxy, options)
            plan_action(Actions::Pulp::Repository::RemoveUnits, options)
          end
        end
      end
    end
  end
end
