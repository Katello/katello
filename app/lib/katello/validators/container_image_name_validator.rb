module Katello
  module Validators
    class ContainerImageNameValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        if value && !ContainerImageNameValidator.validate_name(value)
          record.errors.add(attribute, N_("The generated container repository name is invalid. Please review the lifecycle environment's registry name pattern. It may be caused by special characters in the components that make up the name, like the organization."))
        end
      end

      def self.validate_name(name)
        # regexp-source: https://specs.opencontainers.org/distribution-spec/?v=v1.0.0#DISTRIBUTION-SPEC-26
        if name.empty? || name.length > 255 || !/\A[a-z0-9]+([\-_.][a-z0-9]+)*(\/[a-z0-9]+([\-_.][a-z0-9]+)*)*\z/.match?(name)
          return false
        end
        true
      end
    end
  end
end
