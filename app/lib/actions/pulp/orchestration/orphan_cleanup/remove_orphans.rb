module Actions
  module Pulp
    module Orchestration
      module OrphanCleanup
        class RemoveOrphans < Pulp::Abstract
          def plan(proxy)
            sequence do
              plan_action(Actions::Pulp::OrphanCleanup::RemoveUnneededRepos, proxy) unless proxy.pulp_master?
              plan_action(Actions::Pulp::OrphanCleanup::RemoveOrphans, proxy)
            end
          end
        end
      end
    end
  end
end
