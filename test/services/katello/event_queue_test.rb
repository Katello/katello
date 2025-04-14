require 'katello_test_helper'

module Katello
  class EventQueueTest < ActiveSupport::TestCase
    class MockEvent
      EVENT_TYPE = 'mock_event'.freeze
      def initialize(*)
      end

      def self.retry_seconds
        300
      end
    end

    class MockEventWithMetadata
      EVENT_TYPE = 'mock_event_with_metadata'.freeze
      attr_accessor :metadata

      def initialize(*)
        yield(self) if block_given?
      end
    end

    def setup
      @type = MockEvent::EVENT_TYPE
      EventQueue.register_event(@type, MockEvent)
      EventQueue.register_event(MockEventWithMetadata::EVENT_TYPE, MockEventWithMetadata)
    end

    def test_create_instance
      event = build_stubbed(:katello_event, event_type: @type)

      instance = EventQueue.create_instance(event)

      assert instance.is_a?(MockEvent)
    end

    def test_create_instance_with_metadata
      metadata = { admin_password: 'sekret' }
      event = build_stubbed(:katello_event, event_type: MockEventWithMetadata::EVENT_TYPE, metadata: metadata)

      instance = EventQueue.create_instance(event)

      assert instance.is_a?(MockEventWithMetadata)
      assert_equal metadata, instance.metadata
    end

    def test_clear_events_only_delete_inprogress
      event = create(:katello_event, object_id: 1, event_type: @type)
      EventQueue.clear_events(@type, 1)

      assert_equal [event], Event.where(object_id: 1, event_type: @type)
      event.update(in_progress: true)
      EventQueue.clear_events(@type, 1)

      assert_empty Event.where(object_id: 1, event_type: @type)
    end

    def test_event_class
      assert_equal MockEvent, EventQueue.event_class(@type)
    end

    def test_supported_event_types
      assert_includes Katello::EventQueue.supported_event_types, @type
    end

    def test_next_event
      older = create(:katello_event, event_type: @type, object_id: 1)
      create(:katello_event, event_type: @type, object_id: 1)

      next_event = EventQueue.next_event

      assert_equal older, next_event
    end

    def test_next_event_process_after
      event = create(:katello_event, event_type: @type, object_id: 1, process_after: 5.minutes.from_now)

      # next event should not return an event with a process_after date > now
      assert_nil EventQueue.next_event

      # event will be returned when it is time to run it
      travel_to 6.minutes.from_now do
        assert_equal event, EventQueue.next_event
      end
    end

    def test_mark_in_progress
      # marking a new event received while there are rescheduled
      # events for the same will mark both in progress
      urgent_event = create(:katello_event, event_type: @type, object_id: 1)
      deferred_event = create(:katello_event, event_type: @type, object_id: 1, process_after: 5.minutes.from_now)

      EventQueue.mark_in_progress(urgent_event)
      urgent_event.reload
      deferred_event.reload

      assert urgent_event.in_progress
      assert deferred_event.in_progress
    end

    def test_mark_in_progress_process_after
      # two events with the same object_id but staggered
      # process_after timestamps should not be marked in_progress
      # if we are in between the process_after times
      process_sooner = create(:katello_event, event_type: @type, object_id: 1, process_after: 1.minute.from_now)
      process_later = create(:katello_event, event_type: @type, object_id: 1, process_after: 2.minutes.from_now)

      travel_to 90.seconds.from_now do
        Katello::EventQueue.mark_in_progress(process_sooner)

        process_sooner.reload
        process_later.reload

        assert process_sooner.in_progress
        refute process_later.in_progress
      end
    end

    def test_reschedule_event
      event = create(:katello_event, :in_progress, event_type: @type, object_id: 1, process_after: nil)

      assert Katello::EventQueue.reschedule_event(event)
      event.reload

      refute event.in_progress
      assert event.process_after
    end

    def test_reschedule_event_no_retry
      event = build_stubbed(:katello_event, object_id: 1, event_type: @type)
      Katello::Event.expects(:update).never
      MockEvent.stubs(:retry_seconds)

      assert_nil Katello::EventQueue.reschedule_event(event)
    end

    def test_reschedule_event_expired
      event = build_stubbed(:katello_event, event_type: @type, object_id: 1, created_at: 7.hours.ago)

      assert_equal :expired, Katello::EventQueue.reschedule_event(event)
    end
  end
end
