require 'katello_test_helper'
require_relative '../../../app/lib/katello/event_daemon/monitor.rb'

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
            running: true,
          }
        end
      end

      def test_monitor_running
        monitor = Katello::EventDaemon::Monitor.new(mock_service: MockService)

        MockService.expects(:run).never

        monitor.check_services
      end

      def test_cache_written
        monitor = Katello::EventDaemon::Monitor.new(mock_service: MockService)

        Rails.cache.expects(:write).once

        monitor.check_services
      end

      def test_monitor_not_running
        monitor = Katello::EventDaemon::Monitor.new(mock_service: MockService)
        MockService.stubs(:status).returns(running: false)

        MockService.expects(:run)

        monitor.check_services
      end

      def test_monitor_starting
        Rails.cache.expects(:write).with(
          "katello_event_daemon_status",
          { mock_service: { running: 'starting' } }
        )
        monitor = Katello::EventDaemon::Monitor.new(mock_service: MockService)
        monitor.stubs(:check_services).raises(StandardError) # prevent infinite loop by raising error
        assert_raises(StandardError) { monitor.start }
      end

      def test_check_services_overwrites_initial_status
        monitor = Katello::EventDaemon::Monitor.new(mock_service: MockService)
        mock_status = {
          running: true,
          processed_count: 1,
          failed_count: 0,
        }
        MockService.stubs(:status).returns(mock_status)
        Rails.cache.expects(:write).with(
          "katello_event_daemon_status",
          { mock_service: mock_status }
        )

        monitor.check_services
      end

      def test_monitor_no_status
        monitor = Katello::EventDaemon::Monitor.new(mock_service: MockService)
        MockService.stubs(:status).returns(nil)

        MockService.expects(:run)

        monitor.check_services
      end
    end
  end
end
