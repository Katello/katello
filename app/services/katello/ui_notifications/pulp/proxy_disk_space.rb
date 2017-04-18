module Katello
  module UINotifications
    module Pulp
      class ProxyDiskSpace
        class << self
          def deliver!
            SmartProxy.unscoped.with_content.each do |proxy|
              percentage = proxy.statuses[:pulp].storage['pulp_dir']['percent']
              if percentage[0..2].to_i < 90 && notification_already_exists?(proxy)
                blueprint.notifications.where(subject: proxy).destroy_all
                next
              end
              next unless update_notifications(proxy).empty?
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

          def notification_already_exists?(subject)
            low_disk_notification = Notification.unscoped.find_by(:subject => subject)
            return false if low_disk_notification.blank?
            low_disk_notification.notification_blueprint == blueprint
          end

          def update_notifications(subject)
            return if blueprint.notifications.empty?
            blueprint.notifications.
              where(subject: subject).
              update_attributes(expired_at: blueprint.expired_at)
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
