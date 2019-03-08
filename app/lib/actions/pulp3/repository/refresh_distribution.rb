module Actions
  module Pulp3
    module Repository
      class RefreshDistribution < Pulp3::AbstractAsyncTask
        include Helpers::Presenter

        def plan(repository, smart_proxy)
          action = plan_self(:repository_id => repository.id, :smart_proxy_id => smart_proxy.id)
          plan_action(SaveDistributionReferences, repository, smart_proxy, action.output[:pulp_tasks])
        end

        def invoke_external_task
          repo = ::Katello::Repository.find(input[:repository_id])
          output[:response] = repo.backend_service(smart_proxy).refresh_distributions
        end
      end
    end
  end
end
