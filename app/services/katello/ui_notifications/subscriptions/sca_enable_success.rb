module Katello
  module UINotifications
    module Subscriptions
      class SCAEnableSuccess < UINotifications::AbstractNotification
        private

        def blueprint
          @blueprint ||= NotificationBlueprint.find_by(name: 'sca_enable_success')
        end
      end
    end
  end
end
