module Actions
  module Candlepin
    class AsyncHypervisors < Candlepin::AbstractAsyncTask
      # this action is for tracking an async candlepin task when the task id is already known
      input_format do
        param :task_id
      end

      def invoke_external_task
        self.external_task = { :id => input[:task_id] }
        poll_external_task
      end

      def on_finish
        super
        output[:hypervisors] = ::Actions::Katello::Host::Hypervisors.parse_hypervisors(external_task.delete('resultData'))
      end

      private

      def job_poll_params
        {:result_data => true}
      end
    end
  end
end
