module Katello
  module Validators
    class ContainerImageNameValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        if value && !ContainerImageNameValidator.validate_name(value)
          record.errors.add(attribute, N_("invalid container image name"))
        end
      end

      def self.validate_name(name)
        if name.empty? || name.length > 255 || !/\A([a-z0-9]+[a-z0-9\-_.]*)+(\/[a-z0-9]+[a-z0-9\-_.]*)*\z/.match?(name)
          return false
        end
        true
      end
    end
  end
end
