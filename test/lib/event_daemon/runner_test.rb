require 'katello_test_helper'

module Katello
  module EventDaemon
    class RunnerTest < ActiveSupport::TestCase
      class MockService
        def self.run
        end

        def self.close
        end

        def self.status(*)
          {
            running: true,
          }
        end
      end

      def setup
        Katello::EventDaemon::Runner.instance_variable_set("@services", {})
        Katello::EventDaemon::Runner.instance_variable_set("@lockfile", nil)
        Katello::EventDaemon::Runner.instance_variable_set("@monitor_thread", nil)
        Katello::EventDaemon::Runner.register_service(:mock_service, MockService)
        Katello::EventDaemon::Runner.stubs(:runnable?).returns(true)
        @pid_file = Rails.root.join('tmp', 'test_katello_daemon.pid')
        @lock_file = Rails.root.join('tmp', 'test_katello_daemon.lock')
        Katello::EventDaemon::Runner.stubs(:pid_file).returns(@pid_file)
        Katello::EventDaemon::Runner.stubs(:lock_file).returns(@lock_file)
        FileUtils.rm_f([@pid_file, @lock_file])

        refute Katello::EventDaemon::Runner.started?
      end

      def teardown
        Katello::EventDaemon::Runner.stop
        FileUtils.rm_f([@pid_file, @lock_file])
      end

      def test_start
        Katello::EventDaemon::Runner.start

        assert Katello::EventDaemon::Runner.started?
        Katello::EventDaemon::Runner.stop
      end

      def test_stop_close_services
        Katello::EventDaemon::Runner.start

        MockService.expects(:close)

        Katello::EventDaemon::Runner.stop
      end

      def test_lock_is_held_until_stop
        Katello::EventDaemon::Runner.start
        contender = File.open(@lock_file, File::RDWR | File::CREAT, 0o644)

        refute contender.flock(File::LOCK_EX | File::LOCK_NB)

        Katello::EventDaemon::Runner.stop

        assert contender.flock(File::LOCK_EX | File::LOCK_NB)
      ensure
        contender&.close
      end

      def test_stale_pid_does_not_prevent_start
        FileUtils.mkdir_p(@pid_file.dirname)
        File.write(@pid_file, Process.pid)

        Katello::EventDaemon::Runner.start

        assert Katello::EventDaemon::Runner.started?
        assert Katello::EventDaemon::Runner.owns_lock?
      end

      def test_start_rolls_back_when_writing_pid_fails
        startup_error = IOError.new("PID file is not writable")
        Katello::EventDaemon::Runner.stubs(:write_pid_file).raises(startup_error)
        MockService.expects(:close)

        raised_error = assert_raises(IOError) do
          Katello::EventDaemon::Runner.start
        end

        assert_same startup_error, raised_error
        assert_nil Katello::EventDaemon::Runner.instance_variable_get("@monitor_thread")
        refute Katello::EventDaemon::Runner.owns_lock?
        refute Katello::EventDaemon::Runner.started?
      end

      def test_start_returns_when_lock_is_held
        lock_holder = File.open(@lock_file, File::RDWR | File::CREAT, 0o644)
        lock_holder.flock(File::LOCK_EX)

        Katello::EventDaemon::Runner.start

        assert Katello::EventDaemon::Runner.started?
        refute File.exist?(@pid_file)
      ensure
        lock_holder&.close
      end

      def test_service_status
        expected_status = {
          running: true,
          processed_count: 1,
          failed_count: 0,
        }
        Rails.cache.expects(:read).returns(mock_service: expected_status)
        result = Katello::EventDaemon::Runner.service_status(:mock_service)
        assert_equal result, expected_status
      end
    end
  end
end
