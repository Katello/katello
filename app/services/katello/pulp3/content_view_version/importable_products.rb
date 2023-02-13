module Katello
  module Pulp3
    module ContentViewVersion
      class ImportableProducts
        attr_reader :creatable, :updatable

        def initialize(organization:, metadata_products:)
          @organization = organization
          @metadata_products = metadata_products
          @creatable = []
          @updatable = []
          @products_in_library = ::Katello::Product.in_org(@organization).custom
        end

        def generate!
          # This returns a 2 different list of importable products
          # creatable: products that are part of the metadata but not in the library.
          #            They are ready to be created
          # updatable: products that are both in the metadata and library.
          #            These may contain updates to the product and hence ready to be updated.
          @metadata_products.each do |product|
            next if product.redhat

            library_product = @products_in_library.find { |p| p.label == product.label }
            if library_product
              # add to the update list if product is already available
              updatable << { product: library_product, options: update_params(product) }
            else
              # add to the create list if its  a new product
              creatable << { product: ::Katello::Product.new(create_params(product)) }
            end
          end
        end

        private

        def create_params(metadata_product)
          {
            gpg_key_id: gpg_key_id(metadata_product),
            name: find_unique_name(metadata_product),
            label: metadata_product.label,
            description: metadata_product.description
          }
        end

        def find_unique_name(metadata_product)
          name = metadata_product.name
          i = 1
          while @products_in_library.where(name: name).exists?
            name = "#{metadata_product.name} #{i}"
            i += 1
          end
          name
        end

        def update_params(metadata_product)
          params = {
            gpg_key_id: gpg_key_id(metadata_product),
            description: metadata_product.description
          }

          params
        end

        def gpg_key_id(metadata_product)
          if metadata_product.gpg_key
            @organization.gpg_keys.where(name: metadata_product.gpg_key.name).pick(:id)
          end
        end
      end
    end
  end
end
