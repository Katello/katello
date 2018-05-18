module Katello
  module UINotifications
    module Subscriptions
      class ManifestImportSuccess < UINotifications::AbstractNotification
        private

        def blueprint
          @blueprint ||= NotificationBlueprint.find_by(name: 'manifest_import_success')
        end
      end
    end
  end
end
