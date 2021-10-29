module Actions
  module Pulp
    module OrphanCleanup
      class RemoveUnneededRepos < Pulp::AbstractAsyncTask
        def plan(smart_proxy)
          plan_self(:smart_proxy_id => smart_proxy.id)
        end

        def invoke_external_task
          smart_proxy_service = ::Katello::Pulp::SmartProxyRepository.new(::SmartProxy.unscoped.find(input[:smart_proxy_id]))
          smart_proxy_service.delete_orphaned_repos
        end
      end
    end
  end
end
