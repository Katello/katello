module Katello
  module Agent
    class ClientMessageHandler
      def self.logger
        ::Foreman::Logging.logger('katello/agent')
      end

      # rubocop:disable Metrics/MethodLength
      def self.handle(message)
        logger.debug("client message: #{message.body}")

        dispatch_history_id = message.body.dig(:data, :dispatch_history_id)
        unless dispatch_history_id
          logger.error("No dispatch history in message. Nothing to do")
          return
        end

        dispatch_history = Katello::Agent::DispatchHistory.find_by_id(dispatch_history_id)
        unless dispatch_history
          logger.error("Dispatch history %s could not be found" % dispatch_history_id)
          return
        end

        if message.body[:status] == 'accepted'
          dispatch_history.accepted_at = DateTime.now
        end

        result_details = message.body.dig(:result, :retval, :details)
        if result_details
          dispatch_history.result = result_details
        end

        dispatch_history.save!

        unless dispatch_history.dynflow_execution_plan_id && dispatch_history.dynflow_step_id
          logger.error("No dynflow attributes found for dispatch_history_id=#{dispatch_history.id}")
          return
        end

        task_exists = ForemanTasks::Task.exists?(external_id: dispatch_history.dynflow_execution_plan_id, result: 'pending')

        unless task_exists
          logger.warn("Couldn't find task with external_id=#{dispatch_history.dynflow_execution_plan_id} dispatch_history_id=#{dispatch_history.id}")
          return
        end

        begin
          if message.body[:status] == 'accepted'
            ForemanTasks.dynflow.world.event(dispatch_history.dynflow_execution_plan_id, dispatch_history.dynflow_step_id, 'accepted')
            return
          end

          if result_details
            ForemanTasks.dynflow.world.event(dispatch_history.dynflow_execution_plan_id, dispatch_history.dynflow_step_id, 'finished')
            return
          end
        rescue Dynflow::Error => e
          logger.error("Dynflow error when sending event to execution_plan=#{dispatch_history.dynflow_execution_plan_id} error=#{e.message}")
        end
      end
    end
  end
end
