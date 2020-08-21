module Katello
  module UINotifications
    module Subscriptions
      class SCAEnableError < UINotifications::TaskNotification
        private

        def blueprint
          @blueprint ||= NotificationBlueprint.find_by(name: 'sca_enable_error')
        end
      end
    end
  end
end
