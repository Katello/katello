module Katello
  module Agent
    class ClientMessageHandler
      def self.logger
        ::Foreman::Logging.logger('katello/agent')
      end

      def self.handle(message)
        logger.debug("client message: #{message.content}")

        begin
          json = JSON.parse(message.content)
        rescue
          logger.error("client message didn't contain valid JSON")
          logger.error("message content: #{message.content}")
          return
        end

        dispatch_history_id = json.dig('data', 'dispatch_history_id')
        unless dispatch_history_id
          logger.error("No dispatch history in message. Nothing to do")
          return
        end

        dispatch_history = Katello::Agent::DispatchHistory.find_by_id(dispatch_history_id)
        unless dispatch_history
          logger.error("Dispatch history %s could not be found" % dispatch_history_id)
          return
        end

        if json['status'] == 'accepted'
          logger.debug("Updating accept time for dispatch_history=#{dispatch_history_id}")
          dispatch_history.accepted_at = DateTime.now
        end

        result_details = json.dig('result', 'retval', 'details')
        if result_details
          logger.debug("Updating final status for dispatch_history=#{dispatch_history_id}")
          dispatch_history.status = result_details
        end

        dispatch_history.save!
      end
    end
  end
end
