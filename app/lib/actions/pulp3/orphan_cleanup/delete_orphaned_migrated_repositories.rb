module Actions
  module Pulp3
    module OrphanCleanup
      class DeleteOrphanedMigratedRepositories < Pulp3::AbstractAsyncTask
        def plan(smart_proxy)
          plan_self(:smart_proxy_id => smart_proxy.id)
        end

        def run
          output[:pulp_tasks] = ::Katello::Pulp3::SmartProxyRepository.instance_for_type(smart_proxy).delete_orphan_repositories
        end
      end
    end
  end
end
