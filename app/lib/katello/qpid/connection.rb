require 'qpid_proton'

module Katello
  module Qpid
    class Connection
      class Sender < ::Qpid::Proton::MessagingHandler
        def initialize(url, connection_options, address, messages)
          super()
          @url = url
          @connection_options = connection_options
          @address = address
          @messages = messages
          @sent = 0
          @confirmed = 0
        end

        def on_container_start(container)
          c = container.connect(@url, @connection_options)
          c.open_sender
          @receiver = c.open_receiver(@address) if @address
        end

        def on_sendable(sender)
          @messages.each do |msg|
            msg.reply_to = @receiver.remote_source.address if @receiver
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

        def on_message(_delivery, message)
          opcode = message.properties['qmf.opcode']
          if opcode == '_exception'
            error_code = message.body.dig('_values', 'error_code')
            if error_code != 7 # not found
              error_message = message.body.dig('_values', 'error_text')
              fail(error_message)
            end
          end
        end
      end

      class Receiver < ::Qpid::Proton::MessagingHandler
        def initialize(url, connection_options, address, handler)
          super()
          @url = url
          @connection_options = connection_options.merge(
            idle_timeout: 30
          )
          @address = address
          @handler = handler
        end

        def on_container_start(container)
          c = container.connect(@url, @connection_options)
          c.open_receiver(@address)
        end

        def on_message(_delivery, message)
          received = Katello::Messaging::ReceivedMessage.new(body: message.body)
          @handler.handle(received)
        end
      end

      def initialize(url:, ssl_cert_file:, ssl_key_file:, ssl_ca_file:)
        @url = url
        ssl_domain = ::Qpid::Proton::SSLDomain.new(::Qpid::Proton::SSLDomain::MODE_CLIENT)
        ssl_domain.peer_authentication(::Qpid::Proton::SSLDomain::VERIFY_PEER_NAME)
        ssl_domain.credentials(ssl_cert_file, ssl_key_file, nil) if ssl_cert_file && ssl_key_file
        ssl_domain.trusted_ca_db(ssl_ca_file) if ssl_ca_file
        @connection_options = {
          ssl_domain: ssl_domain,
          sasl_allowed_mechs: 'external',
          virtual_host: URI.parse(url).host
        }
      end

      def delete_queue(queue_name)
        address = "qmf.default.direct"
        message = ::Qpid::Proton::Message.new
        message.subject = 'broker'
        message.address = address
        message.body = {
          '_object_id' => {
            '_object_name' => 'org.apache.qpid.broker:broker:amqp-broker'
          },
          '_method_name' => 'delete',
          '_arguments' => {
            'strict' => true,
            'name' => queue_name,
            'type' => 'queue',
            'properties' => {}
          }
        }

        message.properties = {
          'qmf.opcode' => '_method_request',
          'x-amqp-0-10.app-id' => 'qmf2',
          'method' => 'request'
        }

        sender = Sender.new(@url, @connection_options, address, [message])
        with_connection(sender)
      end

      def send_messages(messages)
        qpid_messages = messages.map do |message|
          msg = ::Qpid::Proton::Message.new
          msg.body = message.to_s
          msg.address = message.recipient_address
          msg
        end
        sender = Sender.new(@url, @connection_options, nil, qpid_messages)
        with_connection(sender)
      end

      def receive_messages(address:, handler:)
        receiver = Receiver.new(@url, @connection_options, address, handler)
        with_connection(receiver)
      end

      def close
        @container&.stop
      end

      def open?
        (@container&.running || 0) > 0
      end

      private

      def with_connection(handler)
        @container = ::Qpid::Proton::Container.new(handler)
        @container.run
      ensure
        close
      end
    end
  end
end
