module Actions
  module Katello
    module ContentViewVersion
      class AutoCreateProducts < Actions::Base
        def plan(organization:, metadata:)
          helper = ::Katello::Pulp3::ContentViewVersion::ImportableProducts.
                      new(organization: organization,
                          metadata: metadata)
          helper.generate!
          concurrence do
            helper.creatable.each do |product|
              plan_action(::Actions::Katello::Product::Create, product[:product], organization)
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
