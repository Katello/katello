module Katello
  module UINotifications
    module Subscriptions
      class ManifestExpiredWarning < ::UINotifications::Base
        CONTENT_LABEL = 'rhel-7-server-rpms'.freeze
        CDN_HOSTNAME = 'cdn.redhat.com'.freeze
        CDN_PATH = '/content/dist/rhel/server/7/listing'.freeze

        def self.deliver!(orgs = ::Organization.all)
          orgs.each do |org|
            next unless redhat_connected?(org)
            content = org.contents.find_by(:label => CONTENT_LABEL)
            product = content&.products&.find { |p| p.key }
            if content && product && product.pools.any?
              if got_403? { product.cdn_resource.get(CDN_PATH) }
                new(org).deliver!
              end
            end
          end
        rescue StandardError => e
          # Do not break actions using notifications even if there is a failure.
          logger.warn("Failed to handle notifications - this is most likely a bug: #{e}")
          logger.debug(e.backtrace.join("\n"))
          false
        end

        def create
          add_notification if update_notifications.zero?
        end

        def update_notifications
          blueprint.notifications.
              where(subject: subject).
              update_all(expired_at: blueprint.expired_at)
        end

        def add_notification
          Notification.create!(
              initiator:  User.anonymous_admin,
              audience: ::Notification::AUDIENCE_ADMIN,
              subject: subject,
              notification_blueprint: blueprint
          )
        end

        def blueprint
          @blueprint ||= NotificationBlueprint.find_by(name: 'manifest_expired_warning')
        end

        def self.got_403?
          yield
          false
        rescue Katello::Errors::SecurityViolation
          true
        end

        def self.redhat_connected?(org)
          org.redhat_provider.repository_url.include?(CDN_HOSTNAME) && !Setting[:content_disconnected]
        end
      end
    end
  end
end
