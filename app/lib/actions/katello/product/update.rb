module Actions
  module Katello
    module Product
      class Update < Actions::EntryAction
        def plan(product, product_params)
          action_subject product
          product.update_attributes!(product_params)
          if product.previous_changes.key?('gpg_key_id')
            plan_action(::Actions::Katello::Product::RepositoriesGpgReset, product)
          end
          if (product.previous_changes.key?('ssl_ca_cert_id') ||
              product.previous_changes.key?('ssl_client_cert_id') ||
              product.previous_changes.key?('ssl_client_key_id'))
            plan_action(::Actions::Katello::Product::RepositoriesCertsReset, product)
          end

          product.reload
          plan_action(::Actions::Pulp::Repos::Update, product) if ::SETTINGS[:katello][:use_pulp]
        end
      end
    end
  end
end
