module Katello
  module EventMonitor
    class PollerThread
      SLEEP_INTERVAL = 3
      STATUS_CACHE_KEY = 'katello_events_status'.freeze

      cattr_accessor :instance

      def self.initialize(logger = nil)
        self.instance ||= self.new(logger)
      end

      def self.close
        if self.instance
          self.instance.close
          self.instance = nil
        end
        reset_status
      end

      def self.run
        initialize
        ::Katello::EventQueue.reset_in_progress
        instance.poll_for_events
      end

      def self.status(refresh: true)
        Rails.cache.fetch(STATUS_CACHE_KEY, force: refresh) do
          instance&.status
        end
      end

      def self.reset_status
        Rails.cache.delete(STATUS_CACHE_KEY)
      end

      def initialize(logger = nil)
        @logger = logger || ::Foreman::Logging.logger('katello/katello_events')
        @failed_count = 0
        @processed_count = 0
      end

      def close
        @logger.info("Stopping Katello Event Monitor")
        @thread.kill if @thread
      end

      def running?
        @thread&.status || false
      end

      def status
        {
          processed_count: @processed_count,
          failed_count: @failed_count,
          running: running?
        }
      end

      def run_event(event)
        @logger.debug("event_queue_event: type=#{event.event_type}, object_id=#{event.object_id}")

        event_instance = nil
        begin
          ::User.as_anonymous_admin do
            event_instance = ::Katello::EventQueue.create_instance(event)
            event_instance.run
          end
        rescue => e
          @failed_count += 1
          @logger.error("event_queue_error: type=#{event.event_type}, object_id=#{event.object_id}")
          @logger.error(e.message)
          @logger.error(e.backtrace.join("\n"))
        ensure
          if event_instance.try(:retry)
            result = ::Katello::EventQueue.reschedule_event(event)
            if result == :expired
              @logger.warn("event_queue_event_expired: type=#{event.event_type} object_id=#{event.object_id}")
            elsif !result.nil?
              @logger.warn("event_queue_rescheduled: type=#{event.event_type} object_id=#{event.object_id}")
            end
          end
          ::Katello::EventQueue.clear_events(event.event_type, event.object_id, event.created_at)
        end
      end

      def poll_for_events
        @thread.kill if @thread
        @thread = Thread.new do
          begin
            @logger.info("Polling Katello Event Queue")
            loop do
              Rails.application.executor.wrap do
                Katello::Util::Support.with_db_connection(@logger) do
                  until (event = ::Katello::EventQueue.next_event).nil?
                    run_event(event)
                    @processed_count += 1
                  end
                end
              end

              sleep SLEEP_INTERVAL
            end
          rescue => e
            @logger.error(e.message)
            @logger.error("Fatal error in Katello Event Monitor")
            self.class.close
          end
        end
      end
    end
  end
end
