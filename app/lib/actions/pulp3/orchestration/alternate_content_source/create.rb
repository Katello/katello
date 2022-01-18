module Actions
  module Pulp3
    module Orchestration
      module AlternateContentSource
        class Create < Pulp3::Abstract
          def plan(acs, smart_proxy)
            sequence do
              # TODO: Should remote creation have its own task?
              # plan_action(Actions::Pulp3::AlternateContentSource::CreateRemote, acs, smart_proxy)
              plan_action(Actions::Pulp3::AlternateContentSource::Create, acs, smart_proxy)
              # TODO: Should the hrefs be committed to acs records in a new action? Is it okay to be in the service class methods?
              #  -> i.e. do we need something like SaveVersions?
            end
          end
        end
      end
    end
  end
end
