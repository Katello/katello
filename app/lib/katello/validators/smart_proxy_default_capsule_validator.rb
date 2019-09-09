module Katello
  module Validators
    class SmartProxyDefaultCapsuleValidator < ActiveModel::Validator
      def validate(record)
        record.errors[:base] << _("Only one default capsule is allowed") if (record.has_feature?('Pulp') && !SmartProxy.with_features('Pulp').blank?)
      end
    end
  end
end
