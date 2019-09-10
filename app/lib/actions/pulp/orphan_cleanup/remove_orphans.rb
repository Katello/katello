module Actions
  module Pulp
    module OrphanCleanup
      class RemoveOrphans < Pulp::AbstractAsyncTask
        def plan(proxy)
          plan_self(:capsule_id => proxy.id)
        end

        def invoke_external_task
          pulp_resources.content.remove_orphans
        end
      end
    end
  end
end
