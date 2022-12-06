module Katello
  module EventDaemon
    class Runner
      STATUS_CACHE_KEY = "katello_event_daemon_status".freeze
      @services = {}
      @cache = ActiveSupport::Cache::MemoryStore.new

      class << self
        def initialize
          FileUtils.mkdir_p(tmp_dir)
          FileUtils.touch(lock_file)
        end

        def settings
          SETTINGS[:katello][:event_daemon]
        end

        def pid
          return unless pid_file && File.exist?(pid_file)

          File.read(pid_file).to_i
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
          return unless pid == Process.pid
          @monitor_thread.kill
          @cache.clear
          @services.values.each(&:close)
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
            Katello::EventDaemon::Monitor.new(@services).start
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
