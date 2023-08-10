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
      event = EventQueue.push_event(@type, 1)

      instance = EventQueue.create_instance(event)

      assert instance.is_a?(MockEvent)
    end

    def test_create_instance_with_metadata
      metadata = { admin_password: 'sekret' }
      event = EventQueue.push_event(MockEventWithMetadata::EVENT_TYPE, 1) do |attrs|
        attrs[:metadata] = metadata
      end

      instance = EventQueue.create_instance(event)

      assert instance.is_a?(MockEventWithMetadata)
      assert_equal metadata, instance.metadata
    end

    def test_clear_events_only_deletes_last
      Event.destroy_all

      event = EventQueue.push_event(@type, 1)
      event2 = EventQueue.push_event(@type, 1)
      event3 = EventQueue.push_event(@type, 1)
      event2.update!(:created_at => event2.created_at - 5.minutes)
      event3.update!(:created_at => event3.created_at + 5.minutes)
      Event.update_all(:in_progress => true)
      refute_empty Event.all

      EventQueue.clear_events(event.event_type, 1, event.created_at)
      assert_equal [event3], Event.all
    end

    def test_clear_events_only_delete_inprogress
      Event.destroy_all

      event = EventQueue.push_event(@type, 1)
      EventQueue.clear_events(@type, 1, event.created_at)

      assert_equal [event], Event.all
      EventQueue.mark_in_progress(event)
      EventQueue.clear_events(@type, 1, event.created_at)

      assert_empty Event.all
    end

    def test_clear_events_delete_process_after
      # Given 2 events E1, E2
      # E1 fails and is rescheduled for later
      # E2 is received, runs successfully
      # E1 should also be removed to avoid redundant run

      EventQueue.push_event(@type, 1)
      failed_event = EventQueue.next_event
      EventQueue.reschedule_event(failed_event)

      EventQueue.push_event(@type, 1)
      success_event = EventQueue.next_event

      EventQueue.clear_events(@type, 1, success_event.created_at)

      assert_empty Event.all
    end

    def test_event_class
      assert_equal MockEvent, EventQueue.event_class(@type)
    end

    def test_supported_event_types
      assert_includes Katello::EventQueue.supported_event_types, @type
    end

    def test_next_event
      EventQueue.register_event('foo', Object)

      event = EventQueue.push_event(@type, 1)
      event2 = EventQueue.push_event('foo', 1)
      event3 = EventQueue.push_event(@type, 1)

      next_event = EventQueue.next_event
      assert_equal event3, next_event
      assert event.reload.in_progress
      assert event3.reload.in_progress
      refute event2.reload.in_progress
    end

    def test_next_event_nil
      EventQueue.register_event('foo', Object)
      Event.destroy_all
      assert_nil EventQueue.next_event

      EventQueue.push_event('foo', 1)
      refute_nil EventQueue.next_event
    end

    def test_next_event_process_after
      event = EventQueue.push_event(@type, 1) do |attrs|
        attrs[:process_after] = Time.zone.now + 5.minutes
      end

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
      urgent_event = EventQueue.push_event(@type, 1)
      deferred_event = EventQueue.push_event(@type, 1) do |attrs|
        attrs[:process_after] = Time.zone.now + 5.minutes
      end

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

      process_sooner = EventQueue.push_event(@type, 1) do |attrs|
        attrs[:process_after] = 1.minute.from_now
      end

      process_later = EventQueue.push_event(@type, 1) do |attrs|
        attrs[:process_after] = 2.minutes.from_now
      end

      travel_to 90.seconds.from_now do
        Katello::EventQueue.mark_in_progress(process_sooner)

        process_sooner.reload
        process_later.reload

        assert process_sooner.in_progress
        refute process_later.in_progress
      end
    end

    def test_reschedule_event
      EventQueue.push_event(@type, 1)
      event = Katello::EventQueue.next_event

      assert Katello::EventQueue.reschedule_event(event)
      event.reload

      refute event.in_progress
      assert event.process_after
    end

    def test_reschedule_event_no_retry
      EventQueue.push_event(@type, 1)
      event = EventQueue.next_event

      MockEvent.stubs(:retry_seconds)
      assert_nil Katello::EventQueue.reschedule_event(event)
      event.reload

      assert event.in_progress
      refute event.process_after
    end

    def test_reschedule_event_expired
      event = EventQueue.push_event(@type, 1)

      travel_to 7.hours.from_now do
        assert_equal :expired, Katello::EventQueue.reschedule_event(event)
      end
    end
  end
end
