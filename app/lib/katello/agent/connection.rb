module Katello
  module Agent
    class Connection
      def initialize
        @connection = ::Katello::Qpid::Connection.new(
          url: settings[:broker_url],
          ssl_cert_file: settings[:broker_ssl_cert_file],
          ssl_key_file: settings[:broker_ssl_key_file],
          ssl_ca_file: settings[:broker_ssl_ca_file]
        )
      end

      def send_messages(messages)
        @connection.send_messages(messages)
      end

      def fetch_agent_messages(handler = ClientMessageHandler)
        @connection.receive_messages(address: settings[:event_queue_name], handler: handler)
      end

      def delete_client_queue(queue_name)
        @connection.delete_queue(queue_name)
      end

      def settings
        SETTINGS[:katello][:agent]
      end

      def open?
        @connection.open?
      end

      def close
        @connection.close
      end
    end
  end
end
