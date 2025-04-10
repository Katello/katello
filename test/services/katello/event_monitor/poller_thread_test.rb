require 'katello_test_helper'

module Katello
  module EventMonitor
    class PollerThreadTest < ActiveSupport::TestCase
      def setup
        @queue = stub(:queue)
      end

      def poller
        @poller ||= Katello::EventMonitor::PollerThread.new(@event, Rails.logger, @queue)
      end

      def test_run_event
        @event = build_stubbed(:katello_event, object_id: 100, event_type: 'whatever')
        event_instance = stub(run: true)

        @queue.expects(:create_instance).returns(event_instance)
        @queue.expects(:mark_in_progress).with(@event)
        @queue.expects(:clear_events).with('whatever', 100)
        @queue.expects(:reschedule_event).never

        poller.run_event
      end

      def test_run_reschedule
        @event = build_stubbed(:katello_event, event_type: 'whatever', object_id: 100)
        event_instance = stub(:event_instance, run: true, retry: true)

        @queue.expects(:create_instance).returns(event_instance)
        @queue.expects(:mark_in_progress).with(@event)
        @queue.expects(:clear_events).with('whatever', 100)
        @queue.expects(:reschedule_event).with(@event).once

        poller.run_event
      end
    end
  end
end
