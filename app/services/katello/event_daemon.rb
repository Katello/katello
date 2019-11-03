module Katello
  class EventDaemon
    class << self
      def initialize
        FileUtils.touch(lock_file)
      end

      def settings
        SETTINGS[:katello][:event_daemon]
      end

      def pid
        return unless pid_file && File.exist?(pid_file)

        File.open(pid_file) { |f| f.read.to_i }
      end

      def pid_file
        pid_dir.join('katello_event_daemon.pid')
      end

      def pid_dir
        Rails.root.join('tmp', 'pids')
      end

      def lock_file
        Rails.root.join('tmp', 'katello_event_daemon.lock')
      end

      def write_pid_file
        return unless pid_file

        FileUtils.mkdir_p(pid_dir)
        File.open(pid_file, 'w') { |f| f.puts Process.pid }
      end

      def stop
        return unless pid == Process.pid
        services.values.each(&:close)
        File.unlink(pid_file) if pid_file && File.exist?(pid_file)
      end

      def start
        return unless runnable?

        lockfile = File.open(lock_file, 'r')
        begin
          lockfile.flock(File::LOCK_EX)
          return if started? # ensure it wasn't started while we waited for the lock

          start_services
          write_pid_file

          at_exit do
            stop
          end

          Rails.logger.info("Katello event daemon started process=#{Process.pid}")
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
        !started? && settings[:enabled] && !::Foreman.in_rake? && !Rails.env.test?
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
