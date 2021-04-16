module Katello
  module UINotifications
    class SystemError < ::UINotifications::Base
      private

      def create
        if unexpired_notifications.zero?
          Notification.create!(
            initiator: initiator,
            audience: ::Notification::AUDIENCE_ADMIN,
            notification_blueprint: blueprint
          )
        end
      end

      def unexpired_notifications
        blueprint.notifications.update_all(expired_at: blueprint.expired_at)
      end

      def blueprint
        @blueprint ||= NotificationBlueprint.find_by(name: 'system_status_error')
      end
    end
  end
end
