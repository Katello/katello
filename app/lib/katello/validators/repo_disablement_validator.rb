module Katello
  module Validators
    class RepoDisablementValidator < ActiveModel::Validator
      def validate(record)
        if record.redhat? && record.enabled_changed? && !record.enabled? && record.promoted?
          record.errors.add(:base, N_("Repository cannot be disabled since it has already been promoted."))
        elsif !record.redhat? && !record.enabled?
          record.errors.add(:base, N_("Custom repositories cannot be disabled."))
        end
      end
    end
  end
end
