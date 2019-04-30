module Actions
  module Pulp3
    module Repository
      class RefreshDistribution < Pulp3::AbstractAsyncTask
        include Helpers::Presenter
        middleware.use Actions::Middleware::ExecuteIfContentsChanged

        def plan(repository, smart_proxy, options = {})
          action = plan_self(:repository_id => repository.id, :smart_proxy_id => smart_proxy.id, :contents_changed => options[:contents_changed])
          plan_action(SaveDistributionReferences, repository, smart_proxy, action.output[:post_sync_skipped] ? {} : action.output[:pulp_tasks], :contents_changed => options[:contents_changed])
        end

        def invoke_external_task
          repo = ::Katello::Repository.find(input[:repository_id])
          output[:response] = repo.backend_service(smart_proxy).refresh_distributions
        end
      end
    end
  end
end
