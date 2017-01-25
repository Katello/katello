module Katello
  module Concerns
    module LocationExtensions
      extend ActiveSupport::Concern

      included do
        after_initialize :set_default_overrides, :if => :new_record?
        before_destroy :deletable?
      end

      def set_default_overrides
        self.ignore_types << ::ProvisioningTemplate.name
        self.ignore_types << ::Hostgroup.name
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
        def default_location_ids
          ids = []
          if ::Setting[:default_location_puppet_content].present?
            ids << ::Location.find_by_title(::Setting[:default_location_puppet_content]).id
          end
          if ::Setting[:default_location_subscribed_hosts].present?
            ids << ::Location.find_by_title(::Setting[:default_location_subscribed_hosts]).id
          end
          ids.uniq
        end
      end
    end
  end
end
