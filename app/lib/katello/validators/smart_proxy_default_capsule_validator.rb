module Katello
  module Validators
    class SmartProxyDefaultCapsuleValidator < ActiveModel::Validator
      def validate(record)
        record.errors[:base] << _("Only one default capsule is allowed") if (record.has_feature?('Pulp') && SmartProxy.pulp_master && SmartProxy.pulp_master != record)
      end
    end
  end
end
