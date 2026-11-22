module Katello
  module EventDaemon
    class Runner
      STATUS_CACHE_KEY = "katello_event_daemon_status".freeze
      @services = {}
      @cache = ActiveSupport::Cache::MemoryStore.new

      class << self
        def settings
          SETTINGS[:katello][:event_daemon]
        end

        def pid
          return unless pid_file

          File.read(pid_file)&.to_i
        rescue Errno::ENOENT
          nil
        end

        def pid_file
          pid_dir.join('katello_event_daemon.pid')
        end

        def tmp_dir
          Rails.root.join('tmp')
        end

        def pid_dir
          tmp_dir.join('pids')
        end

        def lock_file
          tmp_dir.join('katello_event_daemon.lock')
        end

        def write_pid_file
          return unless pid_file

          FileUtils.mkdir_p(pid_dir)
          File.write(pid_file, Process.pid)
        end

        def stop
          return unless owns_lock?

          @monitor_thread&.kill
          @monitor_thread&.join
          @monitor_thread = nil
          @cache.clear
          @services.values.each(&:close)
          FileUtils.rm_f(pid_file) if pid_file
        ensure
          release_lock
        end

        def start
          return unless runnable?
          return unless acquire_lock

          @monitor = Katello::EventDaemon::Monitor.new(@services)
          start_monitor_thread
          write_pid_file

          at_exit do
            stop
          end

          Rails.logger.info("Katello event daemon started process=#{Process.pid}")
        rescue StandardError
          begin
            stop
          rescue StandardError
            # Preserve the startup error if cleanup also fails.
          end
          raise
        end

        def started?
          return true if owns_lock?

          FileUtils.mkdir_p(tmp_dir)
          lockfile = File.open(lock_file, File::RDWR | File::CREAT, 0o644)
          lock_acquired = lockfile.flock(File::LOCK_EX | File::LOCK_NB)
          lockfile.flock(File::LOCK_UN) if lock_acquired
          !lock_acquired
        ensure
          lockfile&.close
        end

        def owns_lock?
          !!(@lockfile && !@lockfile.closed?)
        end

        def acquire_lock
          return false if owns_lock?

          FileUtils.mkdir_p(tmp_dir)
          lockfile = File.open(lock_file, File::RDWR | File::CREAT, 0o644)
          unless lockfile.flock(File::LOCK_EX | File::LOCK_NB)
            lockfile.close
            return false
          end

          @lockfile = lockfile
          true
        end

        def release_lock
          @lockfile&.close
        ensure
          @lockfile = nil
        end

        def start_monitor_thread
          @monitor_thread = Thread.new do
            Rails.application.executor.wrap do
              @monitor.start
            end
          end
        end

        def runnable?
          # avoid accessing the disk on each request
          @cache.fetch('katello_event_daemon_runnable', expires_in: 1.minute) do
            !started? && settings[:enabled] && !::Foreman.in_rake? && !Rails.env.test?
          end
        end

        def register_service(name, klass)
          @services[name] = klass
        end

        def service_status(service_name = nil)
          Rails.cache.read(STATUS_CACHE_KEY)&.dig(service_name)
        end
      end
    end
  end
end
