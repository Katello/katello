module Actions
  module Pulp3
    module Repository
      class Sync < Pulp3::AbstractAsyncTask
        include Helpers::Presenter

        def plan(repo, smart_proxy, options = {})
          plan_self(:repo_id => repo.id, :smart_proxy_id => smart_proxy.id, :options => options)
        end

        def invoke_external_task
          repo = ::Katello::Repository.find(input[:repo_id])
          output[:pulp_tasks] = repo.backend_service(::SmartProxy.unscoped.find(input[:smart_proxy_id])).sync(input[:options])
        end

        def external_task=(tasks)
          output[:create_version] = true
          super
        end

        def finalize
          check_error_details
        end

        def check_error_details
          output[:pulp_tasks].each do |pulp_task|
            error_details = pulp_task.try(:[], "error")
            if error_details && !error_details.nil?
              fail _("An error occurred during the sync \n%{error_message}") % {:error_message => error_details}
            end
          end
        end

        def run_progress
          presenter.progress
        end

        def run_progress_weight
          10
        end

        def presenter
          Presenters::ContentUnitPresenter.new(self)
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
