module Katello
  module Concerns
    module LocationExtensions
      extend ActiveSupport::Concern

      included do
        after_initialize :set_default_overrides, :if => :new_record?
        before_create :set_katello_default
        before_save :refute_katello_default_changed
        before_destroy :deletable?
      end

      def set_default_overrides
        self.ignore_types << ::ProvisioningTemplate.name
        self.ignore_types << ::Hostgroup.name
      end

      def set_katello_default
        if Location.default_location.nil?
          self.katello_default = true
        else
          self.katello_default = false
        end
        true
      end

      def deletable?
        if self.katello_default
          errors.add(:base, _("Cannot delete the default Location"))
          false
        end
      end

      def refute_katello_default_changed
        fail _("katello_default cannot be changed.") if Location.default_location && self.katello_default_changed?
      end

      module ClassMethods
        def default_location
          # In the future, we should have a better way to identify the 'default' location
          Location.where(:katello_default => true).first
        end
      end
    end
  end
end
