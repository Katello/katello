module Actions
  module Pulp3
    module Orchestration
      module AlternateContentSource
        class Update < Pulp3::Abstract
          def plan(acs, smart_proxy)
            sequence do
              plan_action(Actions::Pulp3::AlternateContentSource::UpdateRemote, acs, smart_proxy)
              plan_action(Actions::Pulp3::AlternateContentSource::Update, acs, smart_proxy)
              # TODO: Should the hrefs be committed to acs records in a new action? Is it okay to be in the service class methods?
              #  -> i.e. do we need something like SaveVersions?
            end
          end
        end
      end
    end
  end
end
