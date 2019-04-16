module Actions
  module Pulp
    module Orchestration
      module Repository
        class Sync < Pulp::Abstract
          middleware.use Actions::Middleware::PropagateOutput
          def plan(_repository, _smart_proxy, options)
            sequence do
              action_output = plan_action(Actions::Pulp::Repository::Sync, options).output
              plan_self(:subaction_output => action_output)
            end
          end

          def run
          end
        end
      end
    end
  end
end
