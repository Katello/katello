module Katello
  module UINotifications
    module Subscriptions
      class ManifestDeleteError < UINotifications::TaskNotification
        private

        def blueprint
          @blueprint ||= NotificationBlueprint.find_by(name: 'manifest_delete_error')
        end
      end
    end
  end
end
