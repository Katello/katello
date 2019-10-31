require 'katello_test_helper'

module Katello
  class EventDaemonTest < ActiveSupport::TestCase
    class MockService
      def self.run
      end

      def self.close
      end
    end

    def setup
      Katello::EventDaemon.stubs(:services).returns(mock_service: MockService)
      Katello::EventDaemon.stubs(:runnable?).returns(true)

      @default_settings = {
        enabled: true,
        multiprocess: false,
        lock_file: '/tmp/test_katello_daemon.lock',
        pid_file: '/tmp/test_katello_daemon.pid'
      }

      Katello::EventDaemon.stubs(:settings).returns(@default_settings)
      Katello::EventDaemon.initialize
      refute Katello::EventDaemon.started?
    end

    def teardown
      File.unlink(@default_settings[:lock_file]) if File.exist?(@default_settings[:lock_file])
      File.unlink(@default_settings[:pid_file]) if File.exist?(@default_settings[:pid_file])
      refute Katello::EventDaemon.started?
    end

    def test_start_runs_services
      MockService.expects(:run)

      Katello::EventDaemon.start

      assert Katello::EventDaemon.started?
      Katello::EventDaemon.stop
    end

    def test_start_multiprocess_non_worker
      Katello::EventDaemon.stubs(:settings).returns(@default_settings.merge(multiprocess: true))

      Katello::EventDaemon.start

      refute Katello::EventDaemon.started?
      Katello::EventDaemon.stop
    end

    def test_stop_close_services
      Katello::EventDaemon.start

      MockService.expects(:close)

      Katello::EventDaemon.stop
    end
  end
end
