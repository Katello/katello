module Katello
  module UINotifications
    module Subscriptions
      class SCADisableSuccess < UINotifications::AbstractNotification
        private

        def blueprint
          @blueprint ||= NotificationBlueprint.find_by(name: 'sca_disable_success')
        end
      end
    end
  end
end
