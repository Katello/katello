module Actions
  module Helpers
    module ContentViewAutoPublisher
      def self.included(base)
        base.execution_plan_hooks.use :auto_publish_views, on: :success
        base.execution_plan_hooks.use :auto_publish_view, on: :stopped
        base.middleware.use ::Actions::Middleware::AutoPublishContext
      end

      def auto_publish_views(_execution_plan)
        version = ::Katello::ContentViewVersion.find_by(id: output[:auto_publish_content_view_version_id])
        return unless version

        content_views = ::Katello::ContentView.auto_publishable.where(id: output[:auto_publish_content_view_ids])
        content_views.each do |cv|
          request = ::Katello::ContentViewManager.request_auto_publish(content_view: cv, content_view_version: version)
          next unless request

          trigger_auto_publish(request)
        end
      end

      def auto_publish_view(_execution_plan)
        request = ::Katello::ContentViewAutoPublishRequest.find_by(content_view_id: input[:auto_publish_content_view_id])
        return unless request

        trigger_auto_publish(request)
      end

      def trigger_auto_publish(request)
        ::Katello::ContentViewManager.trigger_auto_publish!(request: request)
      rescue StandardError => e
        begin
          ::Katello::ContentViewManager.auto_publish_log(request, "unrecoverable error #{e}")
          ::Katello::UINotifications::ContentView::AutoPublishFailure.deliver!(request.content_view)
        rescue => second
          ::Katello::ContentViewManager.auto_publish_log(request, "notification delivery failed #{second}")
        end
      end
    end
  end
end
