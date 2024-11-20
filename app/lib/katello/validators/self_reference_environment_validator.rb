module Katello
  module Validators
    class SelfReferenceEnvironmentValidator < ActiveModel::Validator
      def validate(record)
        record.errors.add(:base, _("Environment cannot be in its own promotion path")) if record.priors.select(:id).include? record.id
      end
    end
  end
end
