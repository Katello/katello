module Katello
  module EventQueueSupport
    class MockEvent
      EVENT_TYPE = 'mock_event'.freeze
      def initialize(*)
      end

      def run
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

    EventQueue.register_event(MockEvent::EVENT_TYPE, MockEvent)
    EventQueue.register_event(MockEventWithMetadata::EVENT_TYPE, MockEventWithMetadata)
  end
end
