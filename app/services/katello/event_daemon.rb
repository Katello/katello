module Katello
  class EventDaemon
    class Monitor
      def initialize(service_classes)
        @service_classes = service_classes
      end

      def start
        error = nil
        status = nil
        loop do
          Rails.application.executor.wrap do
            check_services(error, status)
          end
          sleep 15
        end
      end

      def check_services(error, status)
        @service_classes.each do |service_class|
          begin
            status = service_class.status
          rescue => error
            Rails.logger.error("Error occurred while pinging #{service_class}")
            Rails.logger.error(error.message)
            Rails.logger.error(error.backtrace.join("\n"))
          ensure
            if error || !status&.dig(:running)
              begin
                service_class.close
                service_class.run
              rescue => error
                Rails.logger.error("Error occurred while starting #{service_class}")
                Rails.logger.error(error.message)
                Rails.logger.error(error.backtrace.join("\n"))
              ensure
                error = nil
              end
            end
          end
        end
      end
    end

    class << self
      def initialize
        FileUtils.touch(lock_file)
        @cache = ActiveSupport::Cache::MemoryStore.new
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
        @monitor_thread.kill
        services.values.each(&:close)
        File.unlink(pid_file) if pid_file && File.exist?(pid_file)
      end

      def start
        return unless runnable?

        lockfile = File.open(lock_file, 'r')
        begin
          lockfile.flock(File::LOCK_EX)
          return if started? # ensure it wasn't started while we waited for the lock

          start_monitor_thread
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

      def start_monitor_thread
        @monitor_thread = Thread.new do
          Monitor.new(services.values).start
        end
      end

      def runnable?
        # avoid accessing the disk on each request
        @cache.fetch('katello_event_daemon_runnable', expires_in: 1.minute) do
          !started? && settings[:enabled] && !::Foreman.in_rake? && !Rails.env.test?
        end
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
