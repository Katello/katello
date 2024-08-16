require 'katello_test_helper'

module Katello
  module EventMonitor
    class PollerThreadTest < ActiveSupport::TestCase
      def test_run
        Katello::EventMonitor::PollerThread.any_instance.expects(:poll_for_events)

        Katello::EventMonitor::PollerThread.run

        Katello::EventMonitor::PollerThread.close
      end

      def test_run_event
        event = Katello::Event.new(object_id: 100, event_type: 'import_pool')
        Katello::EventMonitor::PollerThread.any_instance.expects(:poll_for_events)
        Katello::Events::ImportPool.any_instance.expects(:run)
        Katello::EventMonitor::PollerThread.run

        Katello::EventMonitor::PollerThread.instance.run_event(event)

        Katello::EventMonitor::PollerThread.close
      end

      def test_status
        status = {
          processed_count: 0,
          failed_count: 0,
          running: false,
        }
        Katello::EventMonitor::PollerThread.initialize

        assert_equal status, Katello::EventMonitor::PollerThread.status
      end
    end
  end
end
