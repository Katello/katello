module Katello
  module UINotifications
    module Subscriptions
      class ManifestRefreshSuccess < UINotifications::AbstractNotification
        private

        def blueprint
          @blueprint ||= NotificationBlueprint.find_by(name: 'manifest_refresh_success')
        end
      end
    end
  end
end
