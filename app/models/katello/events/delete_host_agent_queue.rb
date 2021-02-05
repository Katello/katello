module Katello
  module Events
    class DeleteHostAgentQueue
      EVENT_TYPE = 'delete_host_agent_queue'.freeze

      attr_accessor :metadata

      def initialize(_host_id)
        yield(self) if block_given?
      end

      def run
        if metadata[:queue_name]
          Katello::Agent::Dispatcher.delete_client_queue(queue_name: metadata[:queue_name])
        end
      end
    end
  end
end
