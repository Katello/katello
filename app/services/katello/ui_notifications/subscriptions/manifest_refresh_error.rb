module Katello
  module UINotifications
    module Subscriptions
      class ManifestRefreshError < UINotifications::TaskNotification
        private

        def blueprint
          @blueprint ||= NotificationBlueprint.find_by(name: 'manifest_refresh_error')
        end
      end
    end
  end
end
