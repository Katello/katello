module Actions
  module Pulp3
    module OrphanCleanup
      class DeleteOrphanRepositoryVersions < Pulp3::AbstractAsyncTask
        def plan(smart_proxy)
          plan_self(:smart_proxy_id => smart_proxy.id)
        end

        def run
          cleanup_outputs = ::Katello::Pulp3::SmartProxyRepository.instance_for_type(smart_proxy).delete_orphan_repository_versions
          output[:pulp_tasks] = cleanup_outputs[:pulp_tasks]
          output[:errors] = cleanup_outputs[:errors]
        end
      end
    end
  end
end
