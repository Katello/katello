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
      @lockfile = Tempfile.new
      Katello::EventDaemon.stubs(:services).returns(mock_service: MockService)
      Katello::EventDaemon.stubs(:runnable?).returns(true)
      Katello::EventDaemon.stubs(:settings).returns(enabled: true, multiprocess: false, lock_file: @lockfile.path)
    end

    def test_start_runs_services
      MockService.expects(:run)

      Katello::EventDaemon.start

      assert Katello::EventDaemon.started?
      Katello::EventDaemon.stop
    end

    def test_start_multiprocess_non_worker
      Katello::EventDaemon.stubs(:settings).returns(enabled: true, multiprocess: true, lock_file: @lockfile.path)

      Katello::EventDaemon.start

      refute Katello::EventDaemon.started?
    end

    def test_stop_close_services
      Katello::EventDaemon.start

      MockService.expects(:close)

      Katello::EventDaemon.stop
    end
  end
end
