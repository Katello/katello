module Katello
  module UINotifications
    module Pulp
      class ProxyDiskSpace
        class << self
          def deliver!
            SmartProxy.unscoped.with_content.each do |proxy|
              if percentage < 90 && notification_already_exists?(proxy)
                blueprint.notifications.where(subject: proxy).destroy_all
              elsif update_notifications(proxy).empty? && percentage > 90
                ::Notification.create!(
                  :subject => proxy,
                  :initiator => User.anonymous_admin,
                  :audience => Notification::AUDIENCE_ADMIN,
                  :message => ::UINotifications::StringParser.new(
                    blueprint.message,
                    :subject => proxy,
                    :percentage => percentage
                  ),
                  :notification_blueprint => blueprint
                )
              end
            end
          end

          def notification_already_exists?(subject)
            blueprint.notifications.where(:subject => subject).any?
          end

          def update_notifications(subject)
            notifs = blueprint.notifications
            notifs.where(subject: subject).update_all(expired_at: blueprint.expired_at)
            notifs
          end

          def blueprint
            @blueprint ||= NotificationBlueprint.unscoped.find_by(
              :name => 'pulp_low_disk_space')
          end
        end
      end
    end
  end
end
