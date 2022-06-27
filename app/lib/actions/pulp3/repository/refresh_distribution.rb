module Actions
  module Pulp3
    module Repository
      class RefreshDistribution < Pulp3::AbstractAsyncTask
        include Helpers::Presenter

        def plan(repository, smart_proxy, options = {})
          smart_proxy = SmartProxy.unscoped.find_by(id: smart_proxy) #support bulk actions
          sequence do
            if !repository.unprotected && !options[:assume_content_guard_exists]
              plan_action(::Actions::Pulp3::ContentGuard::Refresh, smart_proxy)
            end

            refresh_options = {
              :repository_id => repository.id,
              :smart_proxy_id => smart_proxy.id
            }
            action = plan_self(refresh_options)

            plan_action(SaveDistributionReferences, repository, smart_proxy, action.output)
          end
        end

        def invoke_external_task
          repo = ::Katello::Repository.find(input[:repository_id])
          repo.backend_service(smart_proxy).with_mirror_adapter.refresh_distributions
        end
      end
    end
  end
end
