module Actions
  module Katello
    module Product
      class Create < Actions::EntryAction
        def plan(product, organization, subscription_start = nil)
          sequence do
            product.provider = organization.anonymous_provider
            product.organization = organization
            product.setup_label_from_name
            product.cp_id = ::Katello::Product.unused_product_id
            product.save!

            plan_action(::Actions::Candlepin::Product::Create,
                        :owner => product.organization.label,
                        :name => product.name,
                        :id => product.cp_id,
                        :multiplier => 1,
                        :attributes => [{:name => "arch", :value => "ALL"}])

            sub_create = plan_action(::Actions::Candlepin::Product::CreateUnlimitedSubscription,
                        :owner_key => organization.label,
                        :product_id => product.cp_id,
                        :start_time => subscription_start)

            subscription_id = sub_create.output[:response][:id]

            action_subject product, :cp_id => product.cp_id

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
