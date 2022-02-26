module Katello
  module Events
    class DeleteLatestContentViewVersion
      EVENT_TYPE = 'delete_latest_content_view_version'.freeze

      attr_reader :content_view
      attr_accessor :metadata, :retry

      def self.retry_seconds
        180
      end

      def initialize(content_view_id)
        @content_view = ::Katello::ContentView.find_by_id(content_view_id)
        Rails.logger.warn "Content View not found for ID #{object_id}" if @content_view.nil?
        yield(self) if block_given?
      end

      def run
        return unless content_view

        begin
          ForemanTasks.async_task(::Actions::Katello::ContentView::Remove, content_view,
                        content_view_versions: [content_view.latest_version_object],
                        content_view_environments: content_view.latest_version_object.content_view_environments)
        rescue => e
          self.retry = true if e.is_a?(ForemanTasks::Lock::LockConflict)
          deliver_failure_notification
          raise e
        end
      end

      private

      def deliver_failure_notification
        ::Katello::UINotifications::ContentView::DelelteLatestVersionFailure.deliver!(content_view)
      end
    end
  end
end
