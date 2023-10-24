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
              plan_self(:smart_proxy_id => proxy.id)
            end
          end
        end

        def finalize
          smart_proxy = ::SmartProxy.unscoped.find(input[:smart_proxy_id])
          if smart_proxy.pulp_mirror?
            ::ForemanTasks.async_task(::Actions::Katello::CapsuleContent::UpdateContentCounts, smart_proxy)
          end
        end
      end
    end
  end
end
