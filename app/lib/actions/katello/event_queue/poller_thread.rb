module Actions
  module Katello
    module EventQueue
      class PollerThread
        SLEEP_INTERVAL = 2
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

        def poll_for_events(suspended_action)
          @thread.kill if @thread
          @thread = Thread.new do
            loop do
              begin
                until (event = ::Katello::EventQueue.next_event).nil?
                  suspended_action.notify_queue_item(event.event_type, event.object_id, event.created_at) if event
                end

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
