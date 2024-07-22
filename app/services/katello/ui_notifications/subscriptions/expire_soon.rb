module Katello
  module UINotifications
    module Subscriptions
      class ExpireSoon
        class << self
          def deliver!
            ::Organization.unscoped.all.each do |organization|
              if (notification = notification_already_exists?(organization))
                next unless organization.expiring_subscriptions.count.to_s ==
                  notification.message.split(' ').first
                notification.update(
                  :message => message(organization),
                  :actions => actions
                )
              else
                next unless organization.expiring_subscriptions.count > 0
                ::Notification.create!(
                  :subject => organization,
                  :initiator => User.anonymous_admin,
                  :audience => Notification::AUDIENCE_SUBJECT,
                  :message => message(organization),
                  :actions => actions,
                  :notification_blueprint => blueprint
                )
              end
            end
          end

          def notification_already_exists?(subject)
            subs_expiration_notification = Notification.unscoped.find_by(:subject => subject)
            return false if subs_expiration_notification.blank? ||
              subs_expiration_notification.notification_blueprint != blueprint
            subs_expiration_notification
          end

          def message(organization)
            ::UINotifications::StringParser.new(
              blueprint.message,
              :expiring_subs => organization.expiring_subscriptions.count,
              :subject => organization,
              :days => Setting[:expire_soon_days]
            )
          end

          def actions
            {
              :links => [
                {
                  :href => "/subscriptions?search=expires<\"#{Setting[:expire_soon_days]} days from now\"",
                  :title => _('Subscriptions'),
                  :external => true,
                }
              ],
            }
          end

          def blueprint
            @blueprint ||= NotificationBlueprint.unscoped.find_by(
              :name => 'subs_expire_soon')
          end
        end
      end
    end
  end
end
