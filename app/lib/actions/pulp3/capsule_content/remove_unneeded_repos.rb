module Actions
  module Pulp3
    module CapsuleContent
      class RemoveUnneededRepos < Pulp3::AbstractAsyncTask
        def plan(smart_proxy)
          plan_self(smart_proxy_id => smart_proxy.id)
        end

        def invoke_external_task
          smart_proxy = SmartProxy.unscoped.find(input[:smart_proxy_id])
          smart_proxy_service = ::Katello::Pulp3::SmartProxyRepository.new(smart_proxy)
          smart_proxy_service.delete_orphaned_repos
        end
      end
    end
  end
end
