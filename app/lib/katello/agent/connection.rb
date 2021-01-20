module Katello
  module Agent
    module Connection
      extend ActiveSupport::Concern

      included do
        @agent_connection = Katello::Qpid::Connection.new

        at_exit do
          close_connection
        end

        def self.send_message(message)
          Rails.logger.info("sending message #{message.to_s}")
          @agent_connection.send_message(message.recipient_address, content: message.to_s)
        end

        def self.fetch_agent_messages(sleep_seconds:)
          @agent_connection.receive_messages(
            address: settings[:queue_name],
            sleep_seconds: sleep_seconds
          ) do |received|
            yield(received)
          end
        end

        def self.close_connection
          @agent_connection.close
        end

        def self.agent_connection_open?
          @agent_connection.open?
        end

        def self.settings
          SETTINGS[:katello][:agent]
        end
      end
    end
  end
end
