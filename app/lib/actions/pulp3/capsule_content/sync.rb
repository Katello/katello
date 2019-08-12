module Actions
  module Pulp3
    module CapsuleContent
      class Sync < Pulp3::AbstractAsyncTask
        def plan(repository, smart_proxy, options = {})
          sequence do
            plan_self(:repo_id => repository.id, :smart_proxy_id => smart_proxy.id, :options => options)
            plan_action(GenerateMetadata, repository, smart_proxy, options)
          end
        end

        def invoke_external_task
          repo = ::Katello::Repository.find(input[:repo_id])
          output[:pulp_tasks] = repo.backend_service(::SmartProxy.unscoped.find(input[:smart_proxy_id])).sync_mirror
        end

        def rescue_strategy_for_self
          # There are various reasons the syncing fails, not all of them are
          # fatal: when fail on syncing, we continue with the task ending up
          # in the warning state, but not locking further syncs
          Dynflow::Action::Rescue::Skip
        end
      end
    end
  end
end
