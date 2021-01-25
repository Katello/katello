require 'qpid_proton'

module Katello
  module Qpid
    class Connection
      class Sender < ::Qpid::Proton::MessagingHandler
        def initialize(url, address, message)
          super()
          @url = url
          @address = address
          @message = message
        end

        def on_container_start(container)
          c = container.connect(@url)
          c.open_sender(@address)
        end

        def on_sendable(sender)
          msg = ::Qpid::Proton::Message.new
          msg.body = @message.to_s
          sender.send(msg)
          sender.close
        end

        def on_tracker_accept(tracker)
          tracker.connection.close
        end
      end

      class Receiver < ::Qpid::Proton::MessagingHandler
        def initialize(url, address, handler)
          super()
          @url = url
          @address = address
          @handler = handler
        end

        def on_container_start(container)
          c = container.connect(@url,
            idle_timeout: 4
          )
          c.open_receiver(@address)
        end

        def on_message(delivery, message)
          received = Katello::Messaging::ReceivedMessage.new(body: message.body)
          @handler.handle(received)

          delivery.accept
        end
      end

      def send_message(address, message)
        sender = Sender.new(settings[:url], address, message)
        with_connection(sender)
      end

      def receive_messages(address:, handler:)
        receiver = Receiver.new(settings[:url], address, handler)
        with_connection(receiver)
      end

      private

      def settings
        SETTINGS[:katello][:qpid]
      end

      def with_connection(handler)
        container = ::Qpid::Proton::Container.new(handler)
        container.run
      ensure
        container&.stop
      end
    end
  end
end
