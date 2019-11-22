module Katello
  class CandlepinListeningService
    TIMEOUT = Qpid::Messaging::Duration::SECOND
    NO_MESSAGE_AVAILABLE_ERROR_TYPE = 'NoMessageAvailable'.freeze
    SLEEP_INTERVAL = 3

    class ConnectionError < StandardError
    end

    class << self
      attr_reader :instance

      def initialize_service(logger, url, address)
        @instance = self.new(logger, url, address)
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
      @logger.info("Stopping Candlepin Listening Service")
      @thread.kill if @thread
      @connection.close
    end

    def retrieve
      result = @receiver.fetch(TIMEOUT)
      result
    rescue => e
      if e.class.name.include? "TransportFailure"
        raise ConnectionError, "failed to connect to #{@url}"
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

    def start
      unless @connection.open?
        @connection.open
        @session = @connection.create_session
        @receiver = @session.create_receiver(@address)
        @logger.info("Candlepin Event Listener started")
      end
      :connected
    rescue => e
      @logger.error("Unable to establish candlepin events connection: #{e.message}")
    end

    def running?
      @connection.open? && @thread&.status || false
    end

    def fetch_message
      {:result => retrieve, :error => nil}
    rescue ConnectionError => e
      {:result => nil, :error => e.message}
    end

    def poll_for_messages
      @thread.kill if @thread
      @thread = Thread.new do
        loop do
          message = fetch_message
          yield(message) if block_given?

          sleep SLEEP_INTERVAL if message[:result].nil?
        end
      end
    end
  end
end
