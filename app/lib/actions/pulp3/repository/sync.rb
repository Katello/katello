module Actions
  module Pulp3
    module Repository
      class Sync < Pulp3::AbstractAsyncTask
        include Helpers::Presenter

        input_format do
          param :smart_proxy_id
          param :pulp_id
          param :task_id # In case we need just pair this action with existing sync task
          param :source_url # allow overriding the feed URL
          param :options # Pulp sync options
        end

        def invoke_external_task
          repo = ::Katello::Repository.find_by(:pulp_id => input[:pulp_id])
          output[:pulp_tasks] = repo.backend_service(::SmartProxy.pulp_master).sync
        end

        def external_task=(tasks)
          output[:contents_changed] = false
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
