module Actions
  module Pulp3
    module CapsuleContent
      class RefreshDistribution < Pulp3::AbstractAsyncTask
        include Helpers::Presenter
        middleware.use Actions::Middleware::ExecuteIfContentsChanged

        def plan(repository, smart_proxy, options = {})
          plan_self(:repository_id => repository.id,
                             :smart_proxy_id => smart_proxy.id,
                             :options => options)
        end

        def invoke_external_task
          smart_proxy = ::SmartProxy.unscoped.find(input[:smart_proxy_id])
          repo = ::Katello::Repository.find(input[:repository_id])
          repo.backend_service(smart_proxy).with_mirror_adapter.refresh_distributions
        end
      end
    end
  end
end
