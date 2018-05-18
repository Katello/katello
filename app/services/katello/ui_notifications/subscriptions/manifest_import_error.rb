module Katello
  module UINotifications
    module Subscriptions
      class ManifestImportError < UINotifications::TaskNotification
        private

        def blueprint
          @blueprint ||= NotificationBlueprint.find_by(name: 'manifest_import_error')
        end
      end
    end
  end
end
