module Actions
  module Candlepin
    module Owner
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
