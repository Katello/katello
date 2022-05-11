module Actions
  module Pulp3
    module Orchestration
      module AlternateContentSource
        class Refresh < Pulp3::Abstract
          def plan(acs, smart_proxy)
            sequence do
              plan_action(Actions::Pulp3::AlternateContentSource::Refresh, acs, smart_proxy)
            end
          end
        end
      end
    end
  end
end
