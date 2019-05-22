module Actions
  module Pulp3
    module Orchestration
      module Repository
        class RemoveUnits < Pulp3::Abstract
          def plan(repository, smart_proxy, repository_id, content_unit_ids, content_type_class)
            sequence do
              plan_action(Actions::Pulp3::Repository::RemoveUnits, repository, smart_proxy, content_unit_ids)
            end
          end
        end
      end
    end
  end
end
