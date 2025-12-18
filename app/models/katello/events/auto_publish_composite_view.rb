module Katello
  module Events
    # Event handler for retrying composite content view auto-publish when a lock conflict occurs.
    # This is used in conjunction with Dynflow chaining:
    # - Dynflow chaining coordinates sibling component CV publishes to avoid race conditions
    # - Event-based retry handles the case when a composite CV publish is already running
    # See: ContentViewVersion#auto_publish_composites!
    class AutoPublishCompositeView
      EVENT_TYPE = 'auto_publish_composite_view'.freeze

      attr_reader :composite_view
      attr_accessor :metadata, :retry

      def self.retry_seconds
        180
      end

      def initialize(composite_view_id)
        @composite_view = ::Katello::ContentView.find_by_id(composite_view_id)
        Rails.logger.warn "Content View not found for ID #{object_id}" if @composite_view.nil?
        yield(self) if block_given?
      end

      def run
        return unless composite_view

        begin
          # Use the same coordination logic as auto_publish_composites! to check for
          # running component tasks and chain if necessary
          ::Katello::ContentViewVersion.trigger_composite_publish_with_coordination(
            composite_view,
            metadata[:description],
            metadata[:version_id],
            calling_task_id: metadata[:calling_task_id]
          )
        rescue => e
          self.retry = true if e.is_a?(ForemanTasks::Lock::LockConflict)
          deliver_failure_notification
          raise e
        end
      end

      private

      def deliver_failure_notification
        ::Katello::UINotifications::ContentView::AutoPublishFailure.deliver!(composite_view)
      end
    end
  end
end
