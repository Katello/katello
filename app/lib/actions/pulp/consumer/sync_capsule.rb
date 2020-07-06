module Actions
  module Pulp
    module Consumer
      class SyncCapsule < ::Actions::Pulp::AbstractAsyncTask
        input_format do
          param :capsule_id, Integer
          param :repo_pulp_id, String
          param :sync_options
        end

        def plan(repository, smart_proxy, options)
          plan_self(:capsule_id => smart_proxy.id, :repo_pulp_id => repository.pulp_id, :sync_options => options)
        end

        def humanized_name
          _("Synchronize capsule content")
        end

        def invoke_external_task
          pulp_resources.repository.sync(input[:repo_pulp_id], override_config: input[:sync_options])
        end

        def run_progress
          # override this method so this task's progress isn't 0.5
          # when it is initiated, skewing the progress bar progress
          self.done? ? 1 : 0.1
        end

        def rescue_strategy_for_self
          if output[:cancelled]
            Dynflow::Action::Rescue::Fail
          else
            Dynflow::Action::Rescue::Skip
          end
        end

        def run_progress_weight
          100
        end
      end
    end
  end
end
