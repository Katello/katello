module Katello
  module Validators
    class ProductUniqueAttributeValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        unique = self.unique_attribute?(record, attribute, value)

        unless unique
          message = _("Product with %{attribute} '%{id}' already exists in this organization.") %
                    {:attribute => attribute, :id => value}
          record.errors[attribute] << message
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
