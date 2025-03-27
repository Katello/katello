module Actions
  module Pulp3
    module Orchestration
      module OrphanCleanup
        class RemoveOrphans < Pulp3::Abstract
          def plan(proxy)
            if proxy.pulp3_enabled?
              sequence do
                if proxy.pulp_mirror?
                  plan_action(Actions::Pulp3::OrphanCleanup::RemoveUnneededRepos, proxy)
                  plan_action(Actions::Pulp3::OrphanCleanup::DeleteOrphanAlternateContentSources, proxy)
                  plan_action(Actions::Pulp3::OrphanCleanup::DeleteOrphanRemotes, proxy)
                end
                # Deleting repos causes orphaned distributions, so delete them before the distributions.
                plan_action(Actions::Pulp3::OrphanCleanup::DeleteOrphanDistributions, proxy)
                plan_action(Actions::Pulp3::OrphanCleanup::DeleteOrphanRepositoryVersions, proxy)
                plan_action(Actions::Pulp3::OrphanCleanup::RemoveOrphans, proxy)
                plan_action(Actions::Pulp3::OrphanCleanup::PurgeCompletedTasks, proxy)
              end
            end
          end
        end
      end
    end
  end
end
