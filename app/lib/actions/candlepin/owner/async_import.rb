module Actions
  module Candlepin
    module Owner
      # This task is for polling the candlepin manifest import job.
      # Candlepin::AbstractAsyncTask uses Actions::Base::Polling
      # (which is an alias for Dynflow::Polling) and defines the run method to initiate polling.
      # Therefore, don't override the run method here or in any dependent tasks.
      class AsyncImport < Candlepin::AbstractAsyncTask
        def poll_external_task(task_id = external_task[:id])
          Rails.logger.info "Polling candlepin task"
          task = ::Katello::Resources::Candlepin::Job.get(task_id, :result_data => true)
          Rails.logger.info task['state']
          task
        end

        def invoke_external_task
          Rails.logger.info "invoke_external_task"
          poll_external_task(input[:task_id])
        end
      end
    end
  end
end
