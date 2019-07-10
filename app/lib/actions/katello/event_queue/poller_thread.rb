module Actions
  module Katello
    module EventQueue
      class PollerThread
        SLEEP_INTERVAL = 2
        COUNT_UPDATE_INTERVAL = 250
        cattr_accessor :instance

        def self.initialize(logger)
          self.instance ||= self.new(logger)
        end

        def self.close
          self.instance.close if self.instance
          self.instance = nil
        end

        def initialize(logger)
          @logger = logger
        end

        def close
          @thread.kill if @thread
        end

        def run_event(event)
          @logger.debug("event_queue_event: #{event.event_type}, #{event.object_id}")

          event_instance = nil
          begin
            ::User.as_anonymous_admin do
              event_instance = ::Katello::EventQueue.create_instance(event)
              event_instance.run
            end
          rescue => e
            @logger.error("event_queue_error: #{event.event_type}, #{event.object_id}")
            @logger.error(e.message)
            @logger.error(e.backtrace.join("\n"))
          ensure
            if event_instance.try(:retry)
              ::Katello::EventQueue.reschedule_event(event)
              @logger.warn("event_queue_rescheduled: type=#{event.event_type} object_id=#{event.object_id}")
            end
            ::Katello::EventQueue.clear_events(event.event_type, event.object_id, event.created_at)
          end
        end

        def poll_for_events(suspended_action)
          @thread.kill if @thread
          @thread = Thread.new do
            loop do
              Rails.application.executor.wrap do
                begin
                  count = 0

                  until (event = ::Katello::EventQueue.next_event).nil?
                    run_event(event)
                    count += 1

                    if count > COUNT_UPDATE_INTERVAL
                      suspended_action.notify_count(count)
                      count = 0
                    end
                  end

                  suspended_action.notify_count(count) if count > 0
                  sleep SLEEP_INTERVAL
                rescue => e
                  suspended_action.notify_fatal(e)
                  raise e
                end
              end
            end
          end
        end
      end
    end
  end
end
