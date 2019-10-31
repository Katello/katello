module Actions
  module Pulp3
    module OrphanCleanup
      class RemoveOrphans < Pulp3::AbstractAsyncTask
        def plan(smart_proxy)
          plan_self(:smart_proxy_id => smart_proxy.id)
        end

        def invoke_external_task
          smart_proxy = SmartProxy.find(input[:smart_proxy_id])
          output[:pulp_tasks] = ::Katello::Pulp3::Repository.delete_orphans(smart_proxy)
        end
      end
    end
  end
end
