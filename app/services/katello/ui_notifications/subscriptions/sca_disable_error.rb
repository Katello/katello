module Katello
  module UINotifications
    module Subscriptions
      class SCADisableError < UINotifications::TaskNotification
        private

        def blueprint
          @blueprint ||= NotificationBlueprint.find_by(name: 'sca_disable_error')
        end
      end
    end
  end
end
