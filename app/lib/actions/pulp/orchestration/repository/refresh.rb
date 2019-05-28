module Actions
  module Pulp
    module Orchestration
      module Repository
        class Refresh < Pulp::Abstract
          def plan(repository, smart_proxy, options = {})
            options[:capsule_id] = smart_proxy.id
            plan_action(Actions::Pulp::Repository::Refresh, repository, options)
          end
        end
      end
    end
  end
end
