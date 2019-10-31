module Katello
  class EventDaemon
    PID_CACHE_KEY = 'katello_event_daemon_pid'.freeze

    class << self
      def settings
        SETTINGS[:katello][:event_daemon]
      end

      def cached_pid
        Rails.cache.fetch(PID_CACHE_KEY)
      end

      def stop
        services.values.each(&:close)
        Rails.cache.delete(PID_CACHE_KEY)
      end

      def start(worker: false)
        return if !runnable? || settings[:multiprocess] && !worker

        lockfile = File.open(settings[:lock_file], 'r')
        begin
          lockfile.flock(File::LOCK_EX)
          return if started? # ensure it wasn't started while we waited for the lock

          start_services

          Rails.cache.write(PID_CACHE_KEY, Process.pid)
          Rails.logger.info("Katello event daemon started process=#{Process.pid} multiprocess=#{settings[:multiprocess]}")
        ensure
          lockfile.flock(File::LOCK_UN)
        end
      end

      def started?
        Process.kill(0, cached_pid)
        true
      rescue Errno::ESRCH, TypeError # process no longer exists or we had no PID cached
        false
      end

      def start_services
        services.values.each(&:run)

        at_exit do
          stop
        end
      end

      def runnable?
        return false if !settings[:enabled] || ::Foreman.in_rake? || Rails.env.test?

        if started?
          Rails.logger.debug("Katello Event Daemon already running; not attempting startup")
          return false
        end

        if defined?(Rails::Console)
          Rails.logger.debug("Not starting Katello Event Daemon in the Rails Console")
          return false
        end

        if $PROGRAM_NAME.match(/spring/)
          Rails.logger.debug("Spring is running in the environment; not starting Katello Event Daemon")
          return false
        end

        if Rails.env.production? && $PROGRAM_NAME.match(/dynflow/)
          Rails.logger.debug("This appears to be the Dynflow process; not starting Katello Event Daemon")
          return false
        end

        true
      end

      def services
        {
          candlepin_events: ::Katello::CandlepinEventListener,
          katello_events: ::Katello::EventMonitor::PollerThread
        }
      end
    end
  end
end
