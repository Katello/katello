module Katello
  module EventMonitor
    class PollerThread
      SLEEP_INTERVAL = 3
      PROCESSED_COUNT_CACHE_KEY = 'katello_events_processed'.freeze
      FAILED_COUNT_CACHE_KEY = 'katello_events_failed'.freeze

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
        instance.poll_for_events
      end

      def self.status
        {
          processed_count: Rails.cache.fetch(PROCESSED_COUNT_CACHE_KEY) { 0 },
          failed_count: Rails.cache.fetch(FAILED_COUNT_CACHE_KEY) { 0 },
          queue_depth: Katello::EventQueue.queue_depth
        }
      end

      def self.reset_status
        Rails.cache.write(PROCESSED_COUNT_CACHE_KEY, 0)
        Rails.cache.write(FAILED_COUNT_CACHE_KEY, 0)
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
          Rails.cache.write(FAILED_COUNT_CACHE_KEY, @failed_count, expires_in: 24.hours)

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
            ActiveRecord::Base.connection_pool.with_connection do
              @logger.info("Polling Katello Event Queue")
              ::Katello::EventQueue.reset_in_progress
              loop do
                until (event = ::Katello::EventQueue.next_event).nil?
                  run_event(event)
                  @processed_count += 1
                  Rails.cache.write(PROCESSED_COUNT_CACHE_KEY, @processed_count, expires_in: 24.hours)
                end

                sleep SLEEP_INTERVAL
              end
            end
          rescue PG::ConnectionBad, ActiveRecord::StatementInvalid, ActiveRecord::ConnectionNotEstablished
            @logger.error("Katello event queue lost database connection")
            try_reconnect
            retry
          end
        end
      end

      def try_reconnect
        @logger.info("Reconnecting to Katello Event Monitor")
        ActiveRecord::Base.connection.reconnect!
      rescue
        sleep 5
        retry
      end
    end
  end
end
