module Katello
  class EventQueue
    class Subscription
      TIMEOUT = 120 # Base this on httpd timeout?

      def wait
        start = Time.zone.now
        loop do
          if Katello.shutting_down?
            Rails.logger.info "Canceling event queue subscription due to shutdown."
            return
          end

          return true if Katello::EventQueue.runnable_events.any?

          elapsed = Time.zone.now - start
          break if elapsed > TIMEOUT

          sleep 2
        end

        nil
      end
    end
  end
end
