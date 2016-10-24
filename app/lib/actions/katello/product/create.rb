module Actions
  module Katello
    module Product
      class Create < Actions::EntryAction
        def plan(product, organization)
          sequence do
            product.provider = organization.anonymous_provider
            product.organization = organization

            cp_create = plan_action(::Actions::Candlepin::Product::Create,
                                    :owner => product.organization.label,
                                    :name => product.name,
                                    :multiplier => 1,
                                    :attributes => [{:name => "arch", :value => "ALL"}])

            cp_id = cp_create.output[:response][:id]

            sub_create = plan_action(::Actions::Candlepin::Product::CreateUnlimitedSubscription,
                        :owner_key => organization.label,
                        :product_id => cp_id)

            subscription_id = sub_create.output[:response][:id]

            product.save!
            action_subject product, :cp_id => cp_id

            plan_self
            plan_action Katello::Product::ReindexSubscriptions, product, subscription_id
          end
        end

        def finalize
          product = ::Katello::Product.find(input[:product][:id])
          product.cp_id = input[:cp_id]
          product.save!
        end

        def humanized_name
          _("Product Create")
        end
      end
    end
  end
end
