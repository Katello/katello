module Katello
  module Validators
    class NoTrailingSpaceValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        NoTrailingSpaceValidator.validate_trailing_space(record, attribute, value)
      end

      def self.validate_trailing_space(record, attribute, value)
        if value && !(value.strip == value)
          record.errors.add(attribute, _("must not contain leading or trailing white spaces."))
        end
      end
    end
  end
end
