#
module Actions
  module Candlepin
    class ConnectionError < StandardError
    end

    class CandlepinListeningService
      RECONNECT_ATTEMPTS = 30
      LOOP_RECEIVE_COUNT = 100
      TIMEOUT = Qpid::Messaging::Duration::SECOND
      NO_MESSAGE_AVAILABLE_ERROR_TYPE = 'NoMessageAvailable'.freeze

      class << self
        attr_reader :instance

        def initialize(logger, url, address)
          @instance ||= self.new(logger, url, address)
        end

        def close
          @instance.close if @instance
          @instance = nil
        end
      end

      def initialize(logger, url, address)
        @url = url
        @address = address
        @connection = create_connection
        @logger = logger
      end

      def create_connection
        Qpid::Messaging::Connection.new(:url => @url, :options => {:transport => 'ssl'})
      end

      def close
        @thread.kill if @thread
        @connection.close
      end

      def retrieve
        result = @receiver.fetch(TIMEOUT)
        result
      rescue => e
        if e.class.name.include? "TransportFailure"
          raise ::Actions::Candlepin::ConnectionError, "failed to connect to #{@url}"
        else
          raise e unless e.class.name.include? NO_MESSAGE_AVAILABLE_ERROR_TYPE
        end
      ensure
        safe_release(result) if result
      end

      def safe_release(message)
        @session.acknowledge(:message => message, :sync => true)
      rescue => e
        @session.release(message)
        raise e
      end

      def start(suspended_action)
        unless @connection.open?
          @connection.open
          @session = @connection.create_session
          @receiver = @session.create_receiver(@address)
        end
        if @connection.open?
          suspended_action.notify_connected
        else
          suspended_action.notify_not_connected("Not Connected")
        end
      rescue => e
        raise e unless e.class.name.include? "TransportFailure"
        suspended_action.notify_not_connected(e.message)
      end

      def fetch_message
        {:result => retrieve, :error => nil}
      rescue ::Actions::Candlepin::ConnectionError => e
        {:result => nil, :error => e.message}
      end

      def poll_for_messages(suspended_action)
        @thread.kill if @thread
        @thread = Thread.new do
          count = 0
          loop do
            begin
              message = fetch_message
              if message[:result]
                result = message[:result]
                suspended_action.notify_message_received(result.message_id, result.subject, result.content)
              elsif message[:error]
                suspended_action.notify_not_connected(message[:error])
                break
              end

              if count >= LOOP_RECEIVE_COUNT || (message[:result].nil? && message[:error].nil?)
                sleep 1
                count = 0
              end
            rescue => e
              suspended_action.notify_fatal(e)
              raise e
            ensure
              count += 1
            end
          end
        end
      end
    end
  end
end
