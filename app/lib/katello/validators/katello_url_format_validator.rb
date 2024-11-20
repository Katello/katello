module Katello
  module Validators
    class KatelloURLFormatValidator < ActiveModel::EachValidator
      include KatelloURLHelper

      def validate_each(record, attribute, value)
        if options[:nil_allowed]
          if options[:nil_allowed].respond_to?(:call)
            return if value.nil? && options[:nil_allowed].call(record)
          else
            return if value.nil?
          end
        end

        attribute_name = options[:field_name] || attribute
        record.errors.add(attribute_name, N_("is invalid")) unless kurl_valid?(value)
      end
    end
  end
end
