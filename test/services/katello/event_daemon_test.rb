require 'katello_test_helper'

module Katello
  class EventDaemonTest < ActiveSupport::TestCase
    class MockService
      def self.run
      end

      def self.close
      end

      def self.status(*)
        {
          running: true
        }
      end
    end

    def setup
      Katello::EventDaemon.stubs(:services).returns(mock_service: MockService)
      Katello::EventDaemon.stubs(:runnable?).returns(true)
      Katello::EventDaemon.stubs(:pid_file).returns(Rails.root.join('tmp', 'test_katello_daemon.pid'))

      refute Katello::EventDaemon.started?
    end

    def test_start
      Katello::EventDaemon.start

      assert Katello::EventDaemon.started?
      Katello::EventDaemon.stop
    end

    def test_stop_close_services
      Katello::EventDaemon.start

      MockService.expects(:close)

      Katello::EventDaemon.stop
    end

    def test_monitor_running
      monitor = Katello::EventDaemon::Monitor.new([MockService])

      MockService.expects(:run).never

      monitor.check_services(nil, nil)
    end

    def test_monitor_not_running
      monitor = Katello::EventDaemon::Monitor.new([MockService])
      MockService.stubs(:status).returns(running: false)

      MockService.expects(:run)

      monitor.check_services(nil, nil)
    end

    def test_monitor_no_status
      monitor = Katello::EventDaemon::Monitor.new([MockService])
      MockService.stubs(:status).returns(nil)

      MockService.expects(:run)

      monitor.check_services(nil, nil)
    end
  end
end
