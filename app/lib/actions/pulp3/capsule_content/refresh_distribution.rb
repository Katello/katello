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
          if distribution_uniqueness_conflict?(error)
            # A concurrent RefreshDistribution created this distribution first.
            # Re-invoke so refresh_distributions finds the existing distribution
            # and issues a partial_update instead. Dynflow will poll the new task.
            # This retry is self-terminating: the second invocation always goes
            # down the partial_update path (lookup finds the existing distribution)
            # and cannot produce another uniqueness conflict.
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
          return false unless error.is_a?(::Katello::Errors::Pulp3Error)
          error.message.include?('base_path') &&
            (error.message.include?('unique') ||
             error.message.include?('Overlaps with existing distribution'))
        end
      end
    end
  end
end
