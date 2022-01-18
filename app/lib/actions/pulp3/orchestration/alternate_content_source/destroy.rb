module Actions
  module Pulp3
    module Orchestration
      module AlternateContentSource
        class Destroy < Pulp3::Abstract
          def plan(acs, smart_proxy)
            sequence do
              plan_action(Actions::Pulp3::AlternateContentSource::Destroy, acs, smart_proxy)
            end
          end
        end
      end
    end
  end
end
