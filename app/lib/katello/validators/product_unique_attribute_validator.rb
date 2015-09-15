module Katello
  module Validators
    class ProductUniqueAttributeValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        unique = self.unique_attribute?(record, attribute, value)

        unless unique
          record.errors[attribute] << _("has already been taken for a product in this organization.")
        end
      end

      def unique_attribute?(record, attribute, value)
        unique = true

        if record.provider && !record.provider.redhat_provider? && record.send("#{attribute}_changed?")
          if Product.in_org(record.provider.organization).where(attribute => value).exists?
            unique = false
          end
        end

        unique
      end
    end
  end
end
