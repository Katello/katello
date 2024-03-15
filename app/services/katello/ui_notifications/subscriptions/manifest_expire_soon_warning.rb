module Katello
  module UINotifications
    module Subscriptions
      class ManifestExpireSoonWarning
        class << self
          def deliver!
            ::Organization.unscoped.all.each do |organization|
              if (notification = existing_notification(organization))
                days_remaining = organization.manifest_expire_days_remaining
                if days_remaining == 0 || days_remaining > Setting[:expire_soon_days].to_i
                  # if the manifest has already expired, delete the notification;
                  # user will have a ManifestExpiredWarning instead.
                  # If user changes the expire_soon_days setting, remove notifications
                  # that are no longer relevant.
                  Rails.logger.debug("ManifestExpireSoonWarning: deleting notification for #{organization.name}")
                  notification.destroy
                  next
                end
                # don't update if the message hasn't changed
                next unless message(organization).to_s !=
                  notification.message.to_s
                notification.update(
                  :message => message(organization),
                  :actions => actions
                )
              else
                next unless organization.manifest_expiring_soon?
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

          def existing_notification(subject)
            matching_notification = Notification.unscoped.find_by(:subject => subject, :notification_blueprint => blueprint)
            return false if matching_notification.blank?
            matching_notification
          end

          def message(organization)
            ::UINotifications::StringParser.new(
              blueprint.message,
              :manifest_expire_date => organization.manifest_expiration_date&.to_date,
              :subject => organization,
              :days_remaining => organization.manifest_expire_days_remaining
            )
          end

          def actions
            {
              :links => [
                {
                  :href => "/subscriptions",
                  :title => _('Subscriptions'),
                  :external => false
                }
              ]
            }
          end

          def blueprint
            @blueprint ||= NotificationBlueprint.unscoped.find_by(
              :name => 'manifest_expire_soon_warning')
          end
        end
      end
    end
  end
end
