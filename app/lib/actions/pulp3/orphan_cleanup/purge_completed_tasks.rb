module Actions
  module Pulp3
    module OrphanCleanup
      class PurgeCompletedTasks < Pulp3::AbstractAsyncTask
        def plan(smart_proxy)
          plan_self(:smart_proxy_id => smart_proxy.id)
        end

        def run
          output[:pulp_tasks] = ::Katello::Pulp3::Api::Core.new(smart_proxy).purge_completed_tasks
        end
      end
    end
  end
end
