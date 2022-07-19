module Katello
  module Validators
    class AlternateContentSourceProductsValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        if value
          if attribute == :product_id
            product = ::Katello::Product.find(value)
            content_type = record.alternate_content_source.content_type
            if product.repositories.with_type(content_type).empty?
              record.errors[attribute] << N_("The product %s has no repositories to add to the alternate content source.") % product.name
            end
          end
        end
      end
    end
  end
end
