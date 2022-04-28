module Actions
  module Pulp3
    module Orchestration
      module AlternateContentSource
        class Create < Pulp3::Abstract
          def plan(acs, smart_proxy)
            sequence do
              plan_action(Actions::Pulp3::AlternateContentSource::CreateRemote, acs, smart_proxy)
              plan_action(Actions::Pulp3::AlternateContentSource::Create, acs, smart_proxy)
            end
          end
        end
      end
    end
  end
end
