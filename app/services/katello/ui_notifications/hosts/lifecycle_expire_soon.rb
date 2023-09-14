module Katello
  module UINotifications
    module Hosts
      class LifecycleExpireSoon
        def self.deliver!
          ::Katello::RhelLifecycleStatus.lifecycles_expire_soon.each do |release, schedule|
            schedule.each do |lifecycle, end_date|
              count = hosts_with_index(release).count
              next if count == 0

              message = message(count: count, release: release, lifecycle: lifecycle, end_date: end_date)
              if (notification = existing_notification(release))
                /[^:]+: (?<number_of_hosts>\d+) hosts/ =~ notification.message
                next if number_of_hosts == count.to_s
                notification.update(message: message)
              else
                ::Notification.create!(
                  :initiator => User.anonymous_admin,
                  :audience => Notification::AUDIENCE_GLOBAL,
                  :message => message,
                  :expired_at => end_date.strftime('%Y-%m-%d'),
                  :notification_blueprint => blueprint
                )
              end
            end
          end
        end

        def self.existing_notification(release)
          blueprint.notifications.where("message like ?", "#{release}%").first
        end

        def self.message(options)
          ::UINotifications::StringParser.new(
            blueprint.message,
            :number_of_hosts => options[:count],
            :release => options[:release],
            :lifecycle => options[:lifecycle].gsub(/_/, " "),
            :end_date => options[:end_date].strftime('%Y-%m-%d'),
            :audience => Notification::AUDIENCE_GLOBAL
          )
        end

        def self.hosts_with_index(release)
          /RHEL(?<major>\d+)/ =~ release
          ::Host::Managed.joins(:operatingsystem, :fact_values, :fact_names)
             .where(fact_names: {name: "distribution::name"})
             .where("fact_values.value like ?", "Red Hat Enterprise Linux%")
             .where(operatingsystem: {major: major})
        end

        def self.blueprint
          @blueprint ||= NotificationBlueprint.find_by(name: 'host_lifecycle_expire_soon')
        end
      end
    end
  end
end
