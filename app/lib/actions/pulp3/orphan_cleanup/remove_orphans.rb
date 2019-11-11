module Actions
  module Pulp3
    module OrphanCleanup
      class RemoveOrphans < Pulp3::AbstractAsyncTask
        def plan(smart_proxy)
          plan_self(:smart_proxy_id => smart_proxy.id)
        end

        def invoke_external_task
          output[:pulp_tasks] = ::Katello::Pulp3::Api::Core.new(smart_proxy).delete_orphans
        end
      end
    end
  end
end
