module Actions
  module Pulp3
    module Repository
      class DeleteDistributions < Pulp3::AbstractAsyncTask
        def plan(repository_id, smart_proxy)
          plan_self(:repository_id => repository_id, :smart_proxy_id => smart_proxy.id)
        end

        def invoke_external_task
          repo = ::Katello::Repository.find(input[:repository_id])
          output[:response] = repo.backend_service(smart_proxy).delete_distributions
        end

        def finalize
          # Only destroy the distribution reference after Pulp task succeeds
          repo = ::Katello::Repository.find(input[:repository_id])
          dist_ref = repo.backend_service(smart_proxy).distribution_reference
          dist_ref&.destroy!
        end
      end
    end
  end
end
