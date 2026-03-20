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
        event_record = stub(event_type: 'fake', object_id: 100, created_at: 1.hour.ago)
        event_instance = mock(run: true)

        Katello::EventQueue.expects(:create_instance).with(event_record).returns(event_instance)

        poller = Katello::EventMonitor::PollerThread.new
        poller.run_event(event_record)
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
