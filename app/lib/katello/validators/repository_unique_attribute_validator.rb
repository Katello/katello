module Katello
  module Validators
    class RepositoryUniqueAttributeValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, _value)
        unique = !record.exist_for_environment?(record.environment, record.content_view, attribute)

        if !unique && record.send("#{attribute}_changed?")
          record.errors[attribute] << _("has already been taken for this product.")
        end
      end
    end
  end
end
