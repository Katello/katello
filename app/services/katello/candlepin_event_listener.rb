module Katello
  class CandlepinEventListener
    STATUS_CACHE_KEY = 'candlepin_events_status'.freeze

    Event = Struct.new(:subject, :content)

    cattr_accessor :client_factory

    @failed_count = 0
    @processed_count = 0

    def self.logger
      ::Foreman::Logging.logger('katello/candlepin_events')
    end

    def self.running?
      @running == true && @client&.running?
    end

    def self.close
      return unless running?

      logger.info("Closing candlepin event listener")
      @client&.close
      reset
    end

    def self.reset
      @processed_count = 0
      @failed_count = 0
      @running = false
      Rails.cache.delete(STATUS_CACHE_KEY)
    end

    def self.run
      @client = client_factory.call
      @client.subscribe do |message|
        handle_message(message)
      end

      @running = true
    end

    def self.status(refresh: true)
      Rails.cache.fetch(STATUS_CACHE_KEY, force: refresh) do
        {
          processed_count: @processed_count,
          failed_count: @failed_count,
          running: running?
        }
      end
    end

    def self.handle_message(message)
      ::Katello::Util::Support.with_db_connection(logger) do
        subject = "#{message.headers['EVENT_TARGET']}.#{message.headers['EVENT_TYPE']}".downcase
        cp_event = Event.new(subject, message.body)
        ::Katello::Candlepin::EventHandler.new(logger).handle(cp_event)
      end
      @processed_count += 1
    rescue => e
      @failed_count += 1
      logger.error("Error handling Candlepin event")
      logger.error(e.message)
      logger.error(e.backtrace.join("\n"))
    end
  end
end
