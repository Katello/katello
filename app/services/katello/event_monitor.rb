module Katello
  class EventMonitor
    STATUS_CACHE_KEY = 'katello_event_monitor_status'.freeze

    Event = Struct.new(:event_type, :object_id, :metadata)

    @processed_count = 0
    @failed_count = 0

    def self.client
      Katello::Messaging::Connection.for_client('katello_event_monitor')
    end

    def self.logger
      ::Foreman::Logging.logger('katello/katello_events')
    end

    def self.running?
      @running == true && client.running?
    end

    def self.close
      return unless running?

      logger.info("Stopping Katello Event Monitor")
      client.close
      reset
    end

    def self.reset
      @processed_count = 0
      @failed_count = 0
      @running = false
      Rails.cache.delete(STATUS_CACHE_KEY)
    end

    def self.run
      client.subscribe('katello.katello', 'katello_events') do |message|
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
      event = Event.new(message.headers['katello_event_type'], message.headers['katello_object_id'], message.body)
      logger.debug("event_queue_event: type=#{event.event_type}, object_id=#{event.object_id}")

      begin
        ::User.as_anonymous_admin do
          event_instance = ::Katello::EventQueue.create_instance(event)
          event_instance.run
        end
        @processed_count += 1
      rescue => e
        @failed_count += 1
        logger.error("event_queue_error: type=#{event.event_type}, object_id=#{event.object_id}")
        logger.error(e.message)
        logger.error(e.backtrace.join("\n"))
      end
    end
  end
end
