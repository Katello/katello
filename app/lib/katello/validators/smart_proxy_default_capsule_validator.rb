module Katello
  module Validators
    class SmartProxyDefaultCapsuleValidator < ActiveModel::Validator
      def validate(record)
        if (record.has_feature?('Pulp') && !SmartProxy.with_features('Pulp').blank? &&
            !(SmartProxy.with_features('Pulp').count == 1 && SmartProxy.with_features('Pulp').include?(record)))
          record.errors[:base] << _("Only one default capsule is allowed. Please check #{SmartProxy.pulp_master.try(:name)}")
        end
      end
    end
  end
end
