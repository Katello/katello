module Actions
  module Katello
    module Product
      class Create < Actions::EntryAction
        def plan(product, organization)
          product.provider = organization.anonymous_provider
          product.organization = organization

          cp_create = plan_action(::Actions::Candlepin::Product::Create,
                                  :name => product.name,
                                  :multiplier => 1,
                                  :attributes => [{:name => "arch", :value => "ALL"}])

          cp_id = cp_create.output[:response][:id]

          plan_action(::Actions::Candlepin::Product::CreateUnlimitedSubscription,
                      :owner_key => organization.label,
                      :product_id => cp_id)
          product.save!
          action_subject product, :cp_id => cp_id

          plan_self
          plan_action Katello::Provider::ReindexSubscriptions, product.provider
        end

        def finalize
          product = ::Katello::Product.find(input[:product][:id])
          product.cp_id = input[:cp_id]
          product.save!
        end

        def humanized_name
          _("Create")
        end
      end
    end
  end
end
