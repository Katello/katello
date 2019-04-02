module Actions
  module Pulp3
    module Orchestration
      module Repository
        class Delete < Pulp3::Abstract
          def plan(repository_id, smart_proxy)
            sequence do
              plan_action(Actions::Pulp3::Repository::DeleteRemote, repository_id, smart_proxy)
              plan_action(Actions::Pulp3::Repository::DeletePublisher, repository_id, smart_proxy)
              plan_action(Actions::Pulp3::Repository::DeleteDistributions, repository_id, smart_proxy)
              plan_action(Actions::Pulp3::Repository::Delete, repository_id, smart_proxy)
            end
          end
        end
      end
    end
  end
end
