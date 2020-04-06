module Actions
  module Katello
    module Product
      class Update < Actions::EntryAction
        def plan(product, product_params)
          action_subject product
          product.update!(product_params)
          if product.previous_changes.key?('gpg_key_id')
            plan_action(::Actions::Katello::Product::RepositoriesGpgReset, product)
          end
          if (product.previous_changes.key?('ssl_ca_cert_id') ||
              product.previous_changes.key?('ssl_client_cert_id') ||
              product.previous_changes.key?('ssl_client_key_id'))
            plan_action(::Actions::Katello::Product::RepositoriesCertsReset, product)
          end

          if product.previous_changes.key?('name')
            plan_action(::Actions::Candlepin::Product::Update, owner: product.organization.label, name: product.name, id: product.cp_id)
            product.subscriptions.each do |subscription|
              plan_action(::Actions::Katello::Subscription::Update, subscription, name: product.name)
            end
          end

          product.reload
        end
      end
    end
  end
end
