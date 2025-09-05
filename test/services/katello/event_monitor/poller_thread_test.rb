require 'katello_test_helper'

module Katello
  module EventMonitor
    class PollerThreadTest < ActiveSupport::TestCase
      let(:poller) { Katello::EventMonitor::PollerThread.new(Rails.logger, @queue) }

      def setup
        @queue = stub(:queue)
      end

      def test_drain_stop_condition
        @queue.expects(:next_event).never

        poller.drain_queue(-> { true })
      end

      def test_drain_queue_empty
        event = build_stubbed(:katello_event)
        @queue.stubs(:next_event).returns(event, nil)

        poller.expects(:run_event).with(event)

        poller.drain_queue(-> { false })
      end

      def test_run_event
        event = build_stubbed(:katello_event, object_id: 100, event_type: 'whatever')
        event_instance = stub(run: true)

        @queue.expects(:create_instance).returns(event_instance)
        @queue.expects(:mark_in_progress).with(event)
        @queue.expects(:clear_events).with('whatever', 100)
        @queue.expects(:reschedule_event).never

        poller.run_event(event)
      end

      def test_run_reschedule
        event = build_stubbed(:katello_event, event_type: 'whatever', object_id: 100)
        event_instance = stub(:event_instance, run: true, retry: true)

        @queue.expects(:create_instance).returns(event_instance)
        @queue.expects(:mark_in_progress).with(event)
        @queue.expects(:clear_events).with('whatever', 100)
        @queue.expects(:reschedule_event).with(event).once

        poller.run_event(event)
      end
    end
  end
end
