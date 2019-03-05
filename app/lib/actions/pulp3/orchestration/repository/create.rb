module Actions
  module Pulp3
    module Orchestration
      module Repository
        class Create < Pulp3::Abstract
          def plan(repository, smart_proxy)
            sequence do
              plan_action(Actions::Pulp3::Repository::Create, repository, smart_proxy)
              plan_action(Actions::Pulp3::Repository::CreateRemote, repository, smart_proxy)
              plan_action(Actions::Pulp3::Repository::CreatePublisher, repository, smart_proxy)
              plan_action(Actions::Pulp3::Repository::CreateVersion, repository, smart_proxy)
            end
          end
        end
      end
    end
  end
end
