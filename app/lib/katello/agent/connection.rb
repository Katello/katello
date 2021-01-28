module Katello
  module Agent
    class Connection
      def send_message(message)
        connection = ::Katello::Qpid::Connection.new(settings[:broker_url])
        connection.send_message(message.recipient_address, message)
      end

      def send_messages(messages)
        connection = ::Katello::Qpid::Connection.new(settings[:broker_url])
        connection.send_messages(messages)
      end

      def fetch_agent_messages(handler = ClientMessageHandler)
        connection = ::Katello::Qpid::Connection.new(settings[:broker_url])
        connection.receive_messages(address: settings[:event_queue_name], handler: handler)
      end

      def settings
        SETTINGS[:katello][:agent]
      end
    end
  end
end
