module Katello
  module UINotifications
    module Subscriptions
      class ManifestDeleteSuccess < UINotifications::AbstractNotification
        private

        def blueprint
          @blueprint ||= NotificationBlueprint.find_by(name: 'manifest_delete_success')
        end
      end
    end
  end
end
