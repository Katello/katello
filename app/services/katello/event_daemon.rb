module Katello
  class EventDaemon
    def self.runnable?
      if defined?(Rails::Console)
        Rails.logger.info("Not starting Katello Event Daemon in the Rails Console")
        return false
      end

      if $PROGRAM_NAME.match(/spring/)
        Rails.logger.info("Spring is running in the environment; not starting Katello Event Daemon")
        return false
      end

      if Rails.env.production? && $PROGRAM_NAME.match(/dynflow/)
        Rails.logger.info("This appears to be the Dynflow process; not starting Katello Event Daemon")
        return false
      end

      if started?
        Rails.logger.info("Katello Event Daemon already running; not attempting startup")
        return false
      end

      !::Foreman.in_rake? && !Rails.env.test? && SETTINGS[:katello][:event_daemon_enabled]
    end

    def self.start
      if runnable?
        services.values.each(&:run)

        at_exit do
          stop
        end

        @pid = Process.pid
      end
    end

    def self.stop
      # in puma clustered mode, we should only stop the daemon
      # from the parent process (where it actually is running), not forked workers
      return unless @pid == Process.pid

      services.values.each(&:close)

      @pid = nil
    end

    def self.started?
      @pid.present?
    end

    def self.services
      {
        candlepin_events: ::Katello::CandlepinEventListener,
        katello_events: ::Katello::EventMonitor::PollerThread
      }
    end
  end
end
