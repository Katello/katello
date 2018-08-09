module Actions
  module Katello
    module EventQueue
      class SuspendedAction
        def initialize(suspended_action)
          @suspended_action = suspended_action
        end

        def notify_count(processed_count)
          @suspended_action << Monitor::Count[processed_count, Time.now]
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
