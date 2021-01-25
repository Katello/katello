module Katello
  module Agent
    class Connection
      def send_message(message)
        connection = ::Katello::Qpid::Connection.new
        connection.send_message(message.recipient_address, message)
      end

      def fetch_agent_messages(handler = ClientMessageHandler)
        connection = ::Katello::Qpid::Connection.new
        connection.receive_messages(address: settings[:queue_name], handler: handler)
      end

      def settings
        SETTINGS[:katello][:agent]
      end
    end
  end
end
