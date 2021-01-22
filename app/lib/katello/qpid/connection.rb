require 'qpid_messaging'

module Katello
  module Qpid
    class Connection
      def initialize
        @connection = ::Qpid::Messaging::Connection.new(
          url: settings[:url],
          options: {
            transport: 'ssl'
          }
        )
      end

      def open
        @connection.open
      end

      def close
        return unless open?
        @connection.close
        Rails.logger.debug("Qpid connection #{self.object_id} closed")
      end

      def send_message(address, message)
        with_connection do |connection|
          session = connection.create_session
          sender = session.create_sender(address)
          send(sender, message)
          sender.close
          session.close
        end
      end

      def send(sender, message)
        Rails.logger.debug("Sending with sender=#{sender.object_id} session=#{sender.session.object_id} connection=#{sender.session.connection.object_id}")
        sender.send(::Qpid::Messaging::Message.new(message))
      end

      # Use a single connection, session, and receiver to fetch messages from a queue
      # Drains messages from the queue and sleeps for the specified time before repeating
      def receive_messages(address:, sleep_seconds: nil)
        with_connection do |connection|
          session = connection.create_session
          receiver = session.create_receiver(address)

          begin
            loop do
              receive(receiver) do |received|
                yield(received)
              end

              break if sleep_seconds.blank?

              sleep(sleep_seconds)
            end
          ensure
            receiver.close
            session.close
          end
        end
      end

      def receive(receiver)
        message = fetch_message(receiver)
        while message
          begin
            received = Katello::Messaging::ReceivedMessage.new(body: message.content)
            yield(received)
          ensure
            ack(message, receiver)
          end
          message = fetch_message(receiver)
        end
      rescue NoMessageAvailable
        # this is not an error for us
      end

      def open?
        @connection&.open?
      end

      private

      def with_connection
        @connection.open unless @connection.open?

        yield(@connection)
      end

      def ack(message, receiver)
        receiver.session.acknowledge(message: message, sync: true)
      rescue => e
        receiver.session.release(message)
        raise e
      end

      def fetch_message(receiver)
        receiver.fetch(::Qpid::Messaging::Duration::SECOND)
      end

      def settings
        SETTINGS[:katello][:qpid]
      end
    end
  end
end
