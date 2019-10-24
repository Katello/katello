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
    end

    def test_start_runs_services
      MockService.expects(:run)

      Katello::EventDaemon.start

      Katello::EventDaemon.stop
    end

    def test_stop_close_services
      Katello::EventDaemon.start

      MockService.expects(:close)

      Katello::EventDaemon.stop
    end
  end
end
