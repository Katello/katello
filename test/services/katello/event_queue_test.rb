require 'katello_test_helper'

module Katello
  class EventQueueTest < ActiveSupport::TestCase
    def setup
      @type = Katello::Events::ImportHostApplicability::EVENT_TYPE
    end

    def test_clear_events_only_deletes_last
      Event.destroy_all

      event = EventQueue.push_event(@type, 1)
      event2 = EventQueue.push_event(@type, 1)
      event3 = EventQueue.push_event(@type, 1)
      event2.update_attributes!(:created_at => event2.created_at - 5.minutes)
      event3.update_attributes!(:created_at => event3.created_at + 5.minutes)
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

    def test_event_class
      assert_equal Katello::Events::ImportHostApplicability, EventQueue.event_class(@type)
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
  end
end
