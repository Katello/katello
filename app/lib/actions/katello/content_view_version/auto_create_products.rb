module Actions
  module Katello
    module ContentViewVersion
      class AutoCreateProducts < Actions::Base
        def plan(opts = {})
          helper = ::Katello::Pulp3::ContentViewVersion::ImportableProducts.
                      new(organization: opts[:import].organization,
                          metadata_products: opts[:import].metadata_map.products)
          helper.generate!
          concurrence do
            helper.creatable.each do |product|
              plan_action(::Actions::Katello::Product::Create, product[:product], opts[:import].organization)
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
