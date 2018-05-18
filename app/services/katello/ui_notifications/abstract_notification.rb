module Katello
  module UINotifications
    class AbstractNotification < ::UINotifications::Base
      protected

      def create
        Notification.create!(
          subject: subject,
          initiator: initiator,
          audience: audience,
          notification_blueprint: blueprint,
          actions: actions
        )
      end

      def audience
        ::Notification::AUDIENCE_SUBJECT
      end

      def actions
        []
      end

      def blueprint
        fail(Foreman::Exception, "must define blueprint in #{self.class} successors")
      end
    end
  end
end
