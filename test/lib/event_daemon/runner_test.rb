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
        Katello::EventDaemon::Runner.register_service(:mock_service, MockService)
        Katello::EventDaemon::Runner.stubs(:runnable?).returns(true)
        Katello::EventDaemon::Runner.stubs(:pid_file).returns(Rails.root.join('tmp', 'test_katello_daemon.pid'))

        refute Katello::EventDaemon::Runner.started?
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
