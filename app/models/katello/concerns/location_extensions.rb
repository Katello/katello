module Katello
  module Concerns
    module LocationExtensions
      extend ActiveSupport::Concern

      included do
        after_initialize :set_default_overrides, :if => :new_record?
        after_save :reset_settings
        before_destroy :assert_deletable
        after_create :associate_default_http_proxy
      end

      def set_default_overrides
        self.ignore_types << ::ProvisioningTemplate.name
        self.ignore_types << ::Hostgroup.name
      end

      def reset_settings
        if saved_change_to_attribute?(:title) && (::Setting[:default_location_subscribed_hosts] == self.title_before_last_save)
          ::Setting[:default_location_subscribed_hosts] = self.title
        end
      end

      def assert_deletable
        throw :abort unless deletable?
      end

      def deletable?
        if ::Location.unscoped.count == 1
          errors.add(
            :base,
            _('Cannot delete the last Location.'))
          false
        elsif title == ::Setting[:default_location_subscribed_hosts]
          errors.add(
            :base,
            _('Cannot delete the default Location for subscribed hosts. If you '\
              'no longer want this Location, change the default Location for '\
              'subscribed hosts under Administer > Settings, tab Content.')
          )
          false
        else
          true
        end
      end

      def associate_default_http_proxy
        if (default_proxy = ::HttpProxy.default_global_content_proxy)
          default_proxy.locations << self
          default_proxy.save
        end
      end

      module ClassMethods
        def default_host_subscribe_location
          ::Location.unscoped.find_by_title(::Setting[:default_location_subscribed_hosts]) if ::Setting[:default_location_subscribed_hosts].present?
        end

        def default_host_subscribe_location!
          location = default_host_subscribe_location
          fail _("Setting 'default_location_subscribed_hosts' is not set to a valid location.") if location.nil?
          location
        end

        def default_location_ids
          [default_host_subscribe_location].compact.map(&:id).uniq
        end
      end
    end
  end
end
