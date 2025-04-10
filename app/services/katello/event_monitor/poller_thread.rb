module Katello
  module EventMonitor
    class PollerThread
      def initialize(event, logger = Rails.logger, queue = Katello::EventQueue)
        @logger = logger
        @queue = queue
        @event = event
        @event_instance = @queue.create_instance(@event)
      end

      def run_event
        Katello::Logging.time("katello event handled") do |data|
          data[:type] = @event.event_type
          data[:object_id] = @event.object_id

          begin
            @marked_in_progress = @queue.mark_in_progress(@event) # Mark in progress first so that unsupported events are also cleared

            ::User.as_anonymous_admin do
              @event_instance.run
            end

            #fail "this is bad"

            @run_complete = true
          ensure
            if @event_instance.try(:retry)
              @rescheduled = @queue.reschedule_event(@event)
            end
            @events_cleared = @queue.clear_events(@event.event_type, @event.object_id)
          end
        end
      end

      def to_hash
        {
          marked_in_progress: @marked_in_progress,
          events_cleared: @events_cleared,
          rescheduled: @rescheduled,
          event: @event.attributes,
          event_class: @event_instance.class.to_s,
          run_complete: @run_complete,
        }
      end
    end
  end
end
