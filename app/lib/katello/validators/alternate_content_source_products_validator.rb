module Katello
  module Validators
    class AlternateContentSourceProductsValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        if value
          if attribute == :product_id
            product = ::Katello::Product.find(value)
            content_type = record.alternate_content_source.content_type
            if product.repositories.with_type(content_type).has_url.empty?
              record.errors.add(attribute, _("%{name} has no %{type} repositories with upstream URLs to add to the alternate content source.") % { name: product.name, type: content_type })
            end
          end
        end
      end
    end
  end
end
