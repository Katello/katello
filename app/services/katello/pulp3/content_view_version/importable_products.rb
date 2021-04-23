module Katello
  module Pulp3
    module ContentViewVersion
      class ImportableProducts
        attr_accessor :creatable, :updatable, :organization, :metadata

        def initialize(organization:, metadata:)
          self.organization = organization
          self.metadata = metadata
          self.creatable = []
          self.updatable = []
        end

        def products_in_library
          # Get the product labels in library
          return @products_in_library unless @products_in_library.blank?
          @products_in_library = Set.new(::Katello::Product.in_org(organization).custom.pluck(:label))
        end

        def generate!
          # This returns a 2 different list of importable products
          # creatable: products that are part of the metadata but not in the library.
          #            They are ready to be created
          # updatable: products that are both in the metadata and library.
          #            These may contain updates to the product and hence ready to be updated.
          metadata_map = Import.metadata_map(metadata, product_only: true, custom_only: true)
          metadata_map.each do |product_label, params|
            params[:gpg_key_id] = Import.create_or_update_gpg!(organization: organization,
                                                            params: params[:gpg_key]).id
            params = params.except(:gpg_key)
            if products_in_library.include? product_label
              # add to the update list if product is already available
              product = ::Katello::Product.in_org(organization).find_by(label: product_label)
              updatable << { product: product, options: params.except(:name, :label) }
            else
              # add to the create list if its  a new product
              creatable << { product: ::Katello::Product.new(params) }
            end
          end
        end
      end
    end
  end
end
