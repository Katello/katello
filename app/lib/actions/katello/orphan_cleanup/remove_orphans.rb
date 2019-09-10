module Actions
  module Katello
    module OrphanCleanup
      class RemoveOrphans < Pulp::Abstract
        input_format do
          param :capsule_id
        end
        def plan(proxy)
          sequence do
            plan_action(Actions::Pulp::Orchestration::OrphanCleanup::RemoveOrphans, proxy)
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
