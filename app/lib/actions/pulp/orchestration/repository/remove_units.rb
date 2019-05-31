module Actions
  module Pulp
    module Orchestration
      module Repository
        class RemoveUnits < Pulp::Abstract
          def plan(repository, _smart_proxy, options)
            options[:repo_id] = repository_id
            plan_action(Actions::Pulp::Repository::RemoveUnits, options)
          end
        end
      end
    end
  end
end
