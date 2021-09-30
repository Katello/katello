module Actions
  module Candlepin
    class AsyncHypervisors < Candlepin::AbstractAsyncTask
      # this action is for tracking an async candlepin task when the task id is already known
      input_format do
        param :task_id
      end

      def poll_external_task(task_id = external_task[:id])
        task = super
        unless ::Katello::Resources::Candlepin::Job.not_finished?(task)
          output[:hypervisors] = ::Actions::Katello::Host::Hypervisors.parse_hypervisors(task.delete('resultData'))
        end
        task
      end

      def invoke_external_task
        poll_external_task(input[:task_id])
      end

      private

      def job_poll_params
        {:result_data => true}
      end
    end
  end
end
