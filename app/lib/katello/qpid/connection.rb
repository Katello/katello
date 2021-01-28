require 'qpid_proton'

module Katello
  module Qpid
    class Connection
      class Sender < ::Qpid::Proton::MessagingHandler
        def initialize(url, address, messages)
          super()
          @url = url
          @address = address
          @messages = messages
          @sent = 0
          @confirmed = 0
        end

        def on_container_start(container)
          c = container.connect(@url)
          #c.open_sender(@address)
          c.open_sender
        end

        def on_sendable(sender)
          @messages.each do |message|
            msg = ::Qpid::Proton::Message.new
            msg.body = message.to_s
            msg.address = message.recipient_address
            sender.send(msg)
            @sent += 1
          end
        ensure
          sender.close
        end

        def on_tracker_accept(tracker)
          @confirmed += 1
          if @confirmed == @sent
            tracker.connection.close
          end
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

        def on_message(_delivery, message)
          received = Katello::Messaging::ReceivedMessage.new(body: message.body)
          @handler.handle(received)
        end
      end

      def initialize(url)
        @url = url
      end

      def send_message(address, message)
        sender = Sender.new(@url, address, [message])
        with_connection(sender)
      end

      def send_messages(messages)
        sender = Sender.new(@url, nil, messages)
        with_connection(sender)
      end

      def receive_messages(address:, handler:)
        receiver = Receiver.new(@url, address, handler)
        with_connection(receiver)
      end

      private

      def with_connection(handler)
        container = ::Qpid::Proton::Container.new(handler)
        container.run
      ensure
        container&.stop
      end
    end
  end
end
