module Actions
  module Pulp2
    module Orchestration
      module Repository
        class Delete < Pulp::Abstract
          def plan(repository, smart_proxy)
            sequence do
              plan_action(Pulp::Repository::Destroy, repository_id: repository.id)
            end
          end
        end
      end
    end
  end
end
