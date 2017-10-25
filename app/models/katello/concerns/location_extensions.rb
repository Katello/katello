module Katello
  module Concerns
    module LocationExtensions
      extend ActiveSupport::Concern

      included do
        after_initialize :set_default_overrides, :if => :new_record?
        after_save :reset_settings
        before_destroy :deletable?
      end

      def set_default_overrides
        self.ignore_types << ::ProvisioningTemplate.name
        self.ignore_types << ::Hostgroup.name
      end

      def reset_settings
        if self.title_changed?
          if ::Setting[:default_location_subscribed_hosts] == self.title_was
            ::Setting[:default_location_subscribed_hosts] = self.title
          end
          if ::Setting[:default_location_puppet_content] == self.title_was
            ::Setting[:default_location_puppet_content] = self.title
          end
        end
      end

      def deletable?
        if ::Location.unscoped.count == 1
          errors.add(
            :base,
            _('Cannot delete the last Location. '\
              'Foreman needs at least one Location to put newly published '\
              'Puppet content and Hosts registered via subscription-manager'))
          false
        elsif title == ::Setting[:default_location_subscribed_hosts]
          errors.add(
            :base,
            _('Cannot delete the default Location for subscribed hosts. If you '\
              'no longer want this Location, change the default Location for '\
              'subscribed hosts under Administer > Settings, tab Content.')
          )
          false
        elsif title == ::Setting[:default_location_puppet_content]
          errors.add(
            :base,
            _('Cannot delete the default Location for Puppet content. If you '\
              'no longer want this Location, change the default Location for '\
              'Puppet content under Administer > Settings, tab Content.')
          )
          false
        else
          true
        end
      end

      module ClassMethods
        def default_puppet_content_location
          ::Location.unscoped.find_by_title(::Setting[:default_location_puppet_content]) if ::Setting[:default_location_puppet_content].present?
        end

        def default_puppet_content_location!
          location = default_puppet_content_location
          fail _("Setting 'default_location_puppet_content' is not set to a valid location.") if location.nil?
          location
        end

        def default_host_subscribe_location
          ::Location.unscoped.find_by_title(::Setting[:default_location_subscribed_hosts]) if ::Setting[:default_location_subscribed_hosts].present?
        end

        def default_host_subscribe_location!
          location = default_host_subscribe_location
          fail _("Setting 'default_location_subscribed_hosts' is not set to a valid location.") if location.nil?
          location
        end

        def default_location_ids
          [default_host_subscribe_location, default_puppet_content_location].compact.map(&:id).uniq
        end
      end
    end
  end
end
