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
            running: true
          }
        end
      end

      def setup
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
    end
  end
end
