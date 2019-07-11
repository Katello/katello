module Katello
  module Events
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
          ForemanTasks.async_task(::Actions::Katello::ContentView::Publish,
                              composite_view,
                              metadata[:description],
                              triggered_by: metadata[:version_id])
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
