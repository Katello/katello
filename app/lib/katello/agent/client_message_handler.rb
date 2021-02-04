module Katello
  module Agent
    class ClientMessageHandler
      def initialize(message)
        logger.debug("client message: #{message.body}")
        @json = parse_message_json(message)
        dispatch_history_id = @json&.dig(:data, :dispatch_history_id)
        @dispatch_history = Katello::Agent::DispatchHistory.find_by_id(dispatch_history_id)

        unless @dispatch_history
          fail("No valid dispatch history in client message")
        end
      end

      def accepted?
        @json[:status] == 'accepted'
      end

      def result
        @json.dig(:result, :retval, :details)
      end

      def handle
        @dispatch_history.accepted_at = DateTime.now if accepted?
        @dispatch_history.result = result if result
        @dispatch_history.save!

        if @dispatch_history.dynflow_execution_plan_id && @dispatch_history.dynflow_step_id
          handle_dynflow_event
        end
      end

      private

      def handle_dynflow_event
        task_exists = ForemanTasks::Task.exists?(external_id: @dispatch_history.dynflow_execution_plan_id, result: 'pending')
        unless task_exists
          logger.warn("Couldn't find pending task with external_id=#{@dispatch_history.dynflow_execution_plan_id} dispatch_history_id=#{@dispatch_history.id}")
        end

        if accepted?
          ForemanTasks.dynflow.world.event(@dispatch_history.dynflow_execution_plan_id, @dispatch_history.dynflow_step_id, 'accepted')
        elsif result
          ForemanTasks.dynflow.world.event(@dispatch_history.dynflow_execution_plan_id, @dispatch_history.dynflow_step_id, 'finished')
        end
      end

      def parse_message_json(message)
        JSON.parse(message.body).with_indifferent_access
      rescue
        nil
      end

      def logger
        ::Foreman::Logging.logger('katello/agent')
      end
    end
  end
end
