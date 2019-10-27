module Katello
  class CandlepinEventListener
    PROCESSED_COUNT_CACHE_KEY = 'candlepin_events_processed'.freeze
    FAILED_COUNT_CACHE_KEY = 'candlepin_events_failed'.freeze
    AMQP_QUEUE_NAME = 'event.org.candlepin.audit.AMQPBusPublisher'.freeze

    CandlepinEvent = Struct.new(:message_id, :subject, :content)

    @logger = ::Foreman::Logging.logger('katello/candlepin_events')
    @failed_count = 0
    @processed_count = 0

    def self.start_service
      loop do
        begin
          result = Katello::CandlepinListeningService.instance.start

          break if result == :connected

          @logger.info("Attempting to restart Candlepin Listening Service")
          sleep 5
        end
      end
    end

    def self.run
      @thread.kill if @thread

      # run in own thread so connecting to qpid won't block the main process
      @thread = Thread.new do
        Rails.application.executor.wrap do
          initialize_listening_service
          start_service

          Katello::CandlepinListeningService.instance.poll_for_messages do |message|
            if message[:result]
              result = message[:result]
              event = CandlepinEvent.new(result.message_id, result.subject, result.content)
              act_on_event(event)
            elsif message[:error]
              @logger.error("Disconnected from Candlepin Listening Service, reconnecting")
              start_service
            end
          end
        end
      end
    rescue => e
      @logger.error("Fatal error in Candlepin Listening Service")
      close
      raise e
    end

    def self.status
      {
        processed_count: Rails.cache.fetch(PROCESSED_COUNT_CACHE_KEY) { @processed_count },
        failed_count: Rails.cache.fetch(FAILED_COUNT_CACHE_KEY) { @failed_count },
        queue_depth: Katello::Resources::Candlepin::Admin.queue_depth(AMQP_QUEUE_NAME)
      }
    end

    def self.reset_status
      Rails.cache.write(PROCESSED_COUNT_CACHE_KEY, 0)
      Rails.cache.write(FAILED_COUNT_CACHE_KEY, 0)
    end

    def self.act_on_event(event)
      ::Katello::Candlepin::EventHandler.new(@logger).handle(event)
      @processed_count += 1

      Rails.cache.write(PROCESSED_COUNT_CACHE_KEY, @processed_count, expires_in: 24.hours)
    rescue => e
      @failed_count += 1
      Rails.cache.write(FAILED_COUNT_CACHE_KEY, @failed_count, expires_in: 24.hours)
      @logger.error("Error handling Candlepin event")
      @logger.error(e.message)
      @logger.error(e.backtrace.join("\n"))
    end

    def self.configured?
      SETTINGS[:katello].key?(:qpid) &&
        SETTINGS[:katello][:qpid].key?(:url) &&
        SETTINGS[:katello][:qpid].key?(:subscriptions_queue_address)
    end

    def self.initialize_listening_service
      if configured?
        Katello::CandlepinListeningService.initialize_service(@logger,
                                           SETTINGS[:katello][:qpid][:url],
                                           SETTINGS[:katello][:qpid][:subscriptions_queue_address])
      else
        fail("Katello has not been configured for qpid.url and qpid.subscriptions_queue_address")
      end
    rescue => e
      @logger.error(e.message)
      @logger.error(e.backtrace)
    end

    def self.close
      Katello::CandlepinListeningService.close
      @thread.kill if @thread
      reset_status
    end
  end
end
