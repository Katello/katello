module Katello
  class CandlepinEventListener
    STATUS_CACHE_KEY = 'candlepin_events_status'.freeze

    CandlepinEvent = Struct.new(:message_id, :subject, :content)

    @logger = ::Foreman::Logging.logger('katello/candlepin_events')
    @failed_count = 0
    @processed_count = 0

    def self.run
      initialize_listening_service

      result = Katello::CandlepinListeningService.instance.start
      return unless result == :connected

      Katello::CandlepinListeningService.instance.poll_for_messages do |message|
        if message[:result]
          result = message[:result]
          event = CandlepinEvent.new(result.message_id, result.subject, result.content)
          act_on_event(event)
        end
      end
    rescue => e
      @logger.error("Fatal error in Candlepin Listening Service")
      close
      raise e
    end

    def self.status(refresh: true)
      Rails.cache.fetch(STATUS_CACHE_KEY, force: refresh) do
        {
          processed_count: @processed_count,
          failed_count: @failed_count,
          running: Katello::CandlepinListeningService.instance&.running? || false
        }
      end
    end

    def self.reset_status
      @processed_count = 0
      @failed_count = 0
      Rails.cache.delete(STATUS_CACHE_KEY)
    end

    def self.act_on_event(event)
      ::Katello::Util::Support.with_db_connection(@logger) do
        ::Katello::Candlepin::EventHandler.new(@logger).handle(event)
      end
      @processed_count += 1
    rescue => e
      @failed_count += 1
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
      reset_status
    end
  end
end
