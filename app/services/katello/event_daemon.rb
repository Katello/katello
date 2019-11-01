module Katello
  class EventDaemon
    class << self
      def initialize
        FileUtils.touch(settings[:lock_file])
      end

      def settings
        SETTINGS[:katello][:event_daemon]
      end

      def pid
        return unless pid_file && File.exist?(pid_file)

        File.open(pid_file) { |f| f.read.to_i }
      end

      def pid_file
        settings[:pid_file]
      end

      def write_pid_file
        return unless pid_file

        File.open(pid_file, 'w') { |f| f.puts Process.pid }
      end

      def stop
        return unless pid == Process.pid
        services.values.each(&:close)
        File.unlink(pid_file) if pid_file && File.exist?(pid_file)
      end

      def start(worker: false)
        return if !runnable? || settings[:multiprocess] && !worker

        lockfile = File.open(settings[:lock_file], 'r')
        begin
          lockfile.flock(File::LOCK_EX)
          return if started? # ensure it wasn't started while we waited for the lock

          start_services
          write_pid_file

          at_exit do
            stop
          end

          Rails.logger.info("Katello event daemon started process=#{Process.pid} multiprocess=#{settings[:multiprocess]}")
        ensure
          lockfile.flock(File::LOCK_UN)
        end
      end

      def started?
        Process.kill(0, pid)
        true
      rescue Errno::ESRCH, TypeError # process no longer exists or we had no PID cached
        false
      end

      def start_services
        services.values.each(&:run)
      end

      def runnable?
        return false if started? || !settings[:enabled] || ::Foreman.in_rake? || Rails.env.test?

        if defined?(Rails::Console)
          Rails.logger.debug("Not starting Katello Event Daemon in the Rails Console")
          return false
        end

        if $PROGRAM_NAME.match(/spring/)
          Rails.logger.debug("Spring is running in the environment; not starting Katello Event Daemon")
          return false
        end

        if $PROGRAM_NAME.match(/dynflow/)
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
