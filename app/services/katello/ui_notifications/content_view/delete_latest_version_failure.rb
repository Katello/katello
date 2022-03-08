module Katello
  module UINotifications
    module ContentView
      class DelelteLatestVersionFailure < ::UINotifications::Base
        private

        def create
          Notification.create!(
            subject: subject,
            initiator: initiator,
            audience: ::Notification::AUDIENCE_ADMIN,
            notification_blueprint: blueprint
          )
        end

        def blueprint
          @blueprint ||= NotificationBlueprint.find_by(name: 'content_view_auto_publish_error')
        end
      end
    end
  end
end
