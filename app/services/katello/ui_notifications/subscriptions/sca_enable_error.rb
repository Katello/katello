module Katello
  module UINotifications
    module Subscriptions
      class SCAEnableError < UINotifications::AbstractNotification
        private

        def blueprint
          @blueprint ||= NotificationBlueprint.find_by(name: 'sca_enable_error')
        end
      end
    end
  end
end
