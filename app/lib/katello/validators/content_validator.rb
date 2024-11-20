module Katello
  module Validators
    class ContentValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        value.encode("UTF-8", 'binary') unless value.blank?
      rescue Encoding::UndefinedConversionError
        record.errors.add(attribute, (options[:message] || _("cannot be a binary file.")))
      end
    end
  end
end
