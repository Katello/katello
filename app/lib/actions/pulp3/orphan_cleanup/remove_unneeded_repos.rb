module Actions
  module Pulp3
    module OrphanCleanup
      class RemoveUnneededRepos < Pulp3::AbstractAsyncTask
        def plan(smart_proxy)
          plan_self(:smart_proxy_id => smart_proxy.id)
        end

        def invoke_external_task
          smart_proxy_service = ::Katello::Pulp3::SmartProxyRepository.new(smart_proxy)
          smart_proxy_service.delete_orphaned_repositories_for_mirror_proxies
        end
      end
    end
  end
end
