module Actions
  module Katello
    module EventQueue
      class SuspendedAction
        def initialize(suspended_action)
          @suspended_action = suspended_action
        end

        def notify_queue_item(event_type, object_id, created_at)
          @suspended_action << Monitor::Event[event_type, object_id, created_at.to_datetime]
        end

        def notify_ready
          @suspended_action << Monitor::Ready
        end

        def notify_fatal(error)
          @suspended_action << Monitor::Fatal[error.backtrace && error.backtrace.join('\n'), error.message, error.class.name]
        end
      end
    end
  end
end
