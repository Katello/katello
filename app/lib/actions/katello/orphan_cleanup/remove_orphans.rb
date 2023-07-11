module Actions
  module Katello
    module OrphanCleanup
      class RemoveOrphans < Actions::Base
        input_format do
          param :capsule_id
        end
        def plan(proxy)
          sequence do
            if proxy.pulp_primary?
              ::Katello::RootRepository.orphaned.destroy_all
              plan_action(RemoveOrphanedContentUnits)
            end
            if proxy.pulp3_enabled?
              plan_action(
                Actions::Pulp3::Orchestration::OrphanCleanup::RemoveOrphans,
                proxy)
            end
          end
        end
      end
    end
  end
end
