require 'katello_test_helper'

module Katello
  module EventDaemon
    class MonitorTest < ActiveSupport::TestCase
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

      def test_monitor_running
        monitor = Katello::EventDaemon::Monitor.new(mock_service: MockService)

        MockService.expects(:run).never

        monitor.check_services(nil, nil)
      end

      def test_cache_written
        monitor = Katello::EventDaemon::Monitor.new(mock_service: MockService)

        Rails.cache.expects(:write).once

        monitor.check_services(nil, nil)
      end

      def test_monitor_not_running
        monitor = Katello::EventDaemon::Monitor.new(mock_service: MockService)
        MockService.stubs(:status).returns(running: false)

        MockService.expects(:run)

        monitor.check_services(nil, nil)
      end

      def test_monitor_no_status
        monitor = Katello::EventDaemon::Monitor.new(mock_service: MockService)
        MockService.stubs(:status).returns(nil)

        MockService.expects(:run)

        monitor.check_services(nil, nil)
      end
    end
  end
end
