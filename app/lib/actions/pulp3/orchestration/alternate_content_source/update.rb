module Actions
  module Pulp3
    module Orchestration
      module AlternateContentSource
        class Update < Pulp3::Abstract
          def plan(acs, smart_proxy)
            sequence do
              plan_action(Actions::Pulp3::AlternateContentSource::UpdateRemote, acs, smart_proxy)
              plan_action(Actions::Pulp3::AlternateContentSource::Update, acs, smart_proxy)
            end
          end
        end
      end
    end
  end
end
