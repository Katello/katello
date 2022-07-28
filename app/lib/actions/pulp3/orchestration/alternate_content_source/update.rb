module Actions
  module Pulp3
    module Orchestration
      module AlternateContentSource
        class Update < Pulp3::Abstract
          def plan(smart_proxy_acs)
            sequence do
              plan_action(Actions::Pulp3::AlternateContentSource::UpdateRemote, smart_proxy_acs)
              plan_action(Actions::Pulp3::AlternateContentSource::Update, smart_proxy_acs)
            end
          end
        end
      end
    end
  end
end
