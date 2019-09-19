module Actions
  module Pulp3
    module Orchestration
      module OrphanCleanup
        class RemoveOrphans < Pulp::Abstract
          def plan(proxy)
            if proxy.pulp3_enabled?
              sequence do
                if proxy.pulp_mirror?
                  plan_action(Actions::Pulp3::OrphanCleanup::RemoveUnneededRepos, proxy)
                end
                plan_action(Actions::Pulp3::OrphanCleanup::DeleteOrphanRepositoryVersions, proxy)
              end
            end
          end
        end
      end
    end
  end
end
