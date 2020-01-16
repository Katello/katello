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

      @client = mock('client')
      EventQueue.stubs(:client).returns(@client)
    end

    def test_create_instance
      event = stub(event_type: 'mock_event', object_id: 100)

      instance = EventQueue.create_instance(event)

      assert instance.is_a?(MockEvent)
    end

    def test_create_instance_with_metadata
      metadata = { admin_password: 'sekret' }
      event = stub(event_type: 'mock_event_with_metadata', object_id: 100, metadata: metadata)

      instance = EventQueue.create_instance(event)

      assert instance.is_a?(MockEventWithMetadata)
      assert_equal metadata, instance.metadata
    end

    def test_event_class
      assert_equal MockEvent, EventQueue.event_class(@type)
    end

    def test_supported_event_types
      assert_includes Katello::EventQueue.supported_event_types, @type
    end
  end
end
