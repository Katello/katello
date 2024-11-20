# encoding: utf-8

module Katello
  module Validators
    class KatelloNameFormatValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        if value
          NoTrailingSpaceValidator.validate_trailing_space(record, attribute, value)
          KatelloNameFormatValidator.validate_length(record, attribute, value)
        else
          record.errors.add(attribute, N_("cannot be blank"))
        end
      end

      def self.validate_length(record, attribute, value, min_length = 1)
        if value && !(value.length >= min_length)
          record.errors.add(attribute, _("must contain at least %s character") % min_length)
        end
      end
    end
  end
end
