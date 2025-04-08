module Katello
  module EventMonitor
    class PollerThread
      def initialize(logger = Rails.logger, queue = Katello::EventQueue)
        @logger = logger
        @queue = queue
      end

      def run_event(event)
        Katello::Logging.time("katello event handled") do |data|
          data[:type] = event.event_type
          data[:object_id] = event.object_id
          data[:expired] = false
          data[:rescheduled] = false

          event_instance = nil
          begin
            ::User.as_anonymous_admin do
              event_instance = @queue.create_instance(event)
              @queue.mark_in_progress(event)
              event_instance.run
            end
          rescue => e
            @logger.error("event_queue_error: type=#{event.event_type}, object_id=#{event.object_id}")
            @logger.error(e.message)
            @logger.error(e.backtrace.join("\n"))
          ensure
            if event_instance.try(:retry)
              result = @queue.reschedule_event(event)
              if result == :expired
                @logger.warn("event_queue_event_expired: type=#{event.event_type} object_id=#{event.object_id}")
              elsif !result.nil?
                @logger.warn("event_queue_rescheduled: type=#{event.event_type} object_id=#{event.object_id}")
              end
            end
            @queue.clear_events(event.event_type, event.object_id, event.created_at)
          end
        end
      end
    end
  end
end
