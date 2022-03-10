module Actions
  module Katello
    module ContentViewVersion
      class AutoCreateProducts < Actions::Base
        def plan(import:)
          helper = ::Katello::Pulp3::ContentViewVersion::ImportableProducts.
                      new(organization: import.organization,
                          metadata_products: import.metadata_map.products)
          helper.generate!
          concurrence do
            helper.creatable.each do |product|
              plan_action(::Actions::Katello::Product::Create, product[:product], import.organization)
            end
            helper.updatable.each do |product|
              plan_action(::Actions::Katello::Product::Update, product[:product], product[:options])
            end
          end
        end
      end
    end
  end
end
