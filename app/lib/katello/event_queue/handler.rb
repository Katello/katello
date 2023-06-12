module Katello
  class EventQueue
    class Handler
      def initialize(event, logger = EventQueue.logger)
        @event = event
        @event_instance = ::Katello::EventQueue.create_instance(@event)
        @logger = logger
      end

      def handle
        Katello::Logging.time("katello event handled") do |data|
          data[:type] = @event.event_type
          data[:object_id] = @event.object_id
          data[:expired] = false
          data[:rescheduled] = false

          begin
            @event_instance.run
          ensure
            if @event_instance.try(:retry)
              result = ::Katello::EventQueue.reschedule_event(@event)
              if result == :expired
                @logger.warn("event_queue_event_expired: type=#{@event.event_type} object_id=#{@event.object_id}")
              elsif !result.nil?
                @logger.warn("event_queue_rescheduled: type=#{@event.event_type} object_id=#{@event.object_id}")
              end
            end
            ::Katello::EventQueue.clear_events(@event.event_type, @event.object_id, @event.created_at)
          end
        end
      end
    end
  end
end
