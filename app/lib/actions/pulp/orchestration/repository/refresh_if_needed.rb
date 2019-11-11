module Actions
  module Pulp
    module Orchestration
      module Repository
        class RefreshIfNeeded < Pulp::Abstract
          def plan(repository, smart_proxy, _options = {})
            plan_action(Actions::Pulp::Repository::Refresh, repository, smart_proxy_id: smart_proxy.id)
          end
        end
      end
    end
  end
end
