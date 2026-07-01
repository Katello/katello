module Actions
  module Pulp3
    module CapsuleContent
      class RefreshDistribution < Pulp3::AbstractAsyncTask
        def plan(repository, smart_proxy)
          plan_self(:repository_id => repository.id,
                             :smart_proxy_id => smart_proxy.id)
        end

        def invoke_external_task
          repo.backend_service(smart_proxy).with_mirror_adapter.refresh_distributions
        end

        def rescue_external_task(error)
          if distribution_uniqueness_conflict?(error) && !retried_distribution_refresh?
            # A concurrent RefreshDistribution created this distribution first.
            # Re-invoke so refresh_distributions finds the existing distribution
            # and issues a partial_update instead. Dynflow will poll the new task.
            # Only retry once; if the follow-up refresh still conflicts, fall back
            # to the parent error handling rather than replaying indefinitely.
            output[:retried_distribution_refresh] = true
            self.external_task = invoke_external_task
          else
            super
          end
        end

        private

        def repo
          @repo ||= ::Katello::Repository.find(input[:repository_id])
        end

        def smart_proxy
          @smart_proxy ||= super
        end

        def distribution_uniqueness_conflict?(error)
          error.is_a?(::Katello::Errors::Pulp3Error) &&
            ::Katello::Pulp3::DistributionConflict.create_race?(error)
        end

        def retried_distribution_refresh?
          output[:retried_distribution_refresh]
        end
      end
    end
  end
end
