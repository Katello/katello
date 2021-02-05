module Katello
  module Agent
    class Connection
      def send_messages(messages)
        connection = ::Katello::Qpid::Connection.new(settings[:broker_url])
        connection.send_messages(messages)
      end

      def fetch_agent_messages(handler = ClientMessageHandler)
        connection = ::Katello::Qpid::Connection.new(settings[:broker_url])
        connection.receive_messages(address: settings[:event_queue_name], handler: handler)
      end

      def delete_client_queue(queue_name)
        connection = ::Katello::Qpid::Connection.new(settings[:broker_url])
        connection.delete_queue(queue_name)
      end

      def settings
        SETTINGS[:katello][:agent]
      end
    end
  end
end
