module Katello
  module Validators
    class KatelloLabelFormatValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        if value
          record.errors.add(attribute, N_("cannot contain characters other than ascii alpha numerals, '_', '-'. ")) unless value =~ /\A[a-zA-Z0-9_\-]+\z/
          NoTrailingSpaceValidator.validate_trailing_space(record, attribute, value)
          KatelloLabelFormatValidator.validate_length(record, attribute, value)
        else
          record.errors.add(attribute, N_("can't be blank"))
        end
      end

      def self.validate_length(record, attribute, value, max_length = 128, min_length = 1)
        if value
          record.errors.add(attribute, N_("cannot contain more than %s characters") % max_length) unless value.length <= max_length
          record.errors.add(attribute, N_("must contain at least %s character") % min_length) unless value.length >= min_length
        end
      end
    end
  end
end
