module Actions
  module Pulp3
    module Orchestration
      module Repository
        class Update < Pulp3::Abstract
          def plan(repository, smart_proxy)
            sequence do
              plan_action(Actions::Pulp3::Repository::UpdateRepository, repository, smart_proxy)
              #plan_action(Actions::Pulp3::Repository::UpdateRemote, repository, smart_proxy)
              plan_action(Actions::Pulp3::Repository::UpdateDistributions, repository, smart_proxy)
            end
          end
        end
      end
    end
  end
end
