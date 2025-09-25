module Katello
  module EventMonitor
    class PollerThread
      def initialize(logger = Rails.logger, queue = Katello::EventQueue)
        @logger = logger
        @queue = queue
      end

      def drain_queue(stop_condition)
        until stop_condition.call || (event = @queue.next_event).nil?
          Katello::Logging.time('katello event handled') do |data|
            data[:event_type] = event.event_type
            data[:object_id] = event.object_id
            run_event(event)
          end
        end
      end

      def run_event(event)
        @queue.mark_in_progress(event)
        begin
          event_instance = @queue.create_instance(event)
          event_instance.run
        ensure
          if event_instance.try(:retry)
            @queue.reschedule_event(event)
          end
          @queue.clear_events(event.event_type, event.object_id)
        end
      end
    end
  end
end
