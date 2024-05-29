module Katello
  # TODO: Move this class to app/lib/katello/event_daemon/services with other service definitions
  class CandlepinEventListener
    Event = Struct.new(:subject, :content)

    cattr_accessor :client_factory

    @failed_count = 0
    @processed_count = 0

    def self.logger
      ::Foreman::Logging.logger('katello/candlepin_events')
    end

    def self.running?
      @client&.running? || false
    end

    def self.close
      if @client&.close
        logger.info("Closed candlepin event listener")
      end
      reset
    end

    def self.reset
      @processed_count = 0
      @failed_count = 0
      @client = nil
    end

    def self.run
      @client = client_factory.call
      @client.subscribe do |message|
        handle_message(message)
      end
    end

    def self.status
      {
        processed_count: @processed_count,
        failed_count: @failed_count,
        running: running?,
      }
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
