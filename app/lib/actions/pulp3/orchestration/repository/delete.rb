module Actions
  module Pulp3
    module Orchestration
      module Repository
        class Delete < Pulp3::Abstract
          def plan(repository, smart_proxy)
            sequence do
              plan_action(Actions::Pulp3::Repository::DeleteRemote, repository.id, smart_proxy) if repository.remote_href
              plan_action(Actions::Pulp3::Repository::DeleteDistributions, repository.id, smart_proxy)
              plan_action(Actions::Pulp3::Repository::Delete, repository.id, smart_proxy)
            end
          end
        end
      end
    end
  end
end
