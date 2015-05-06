module Actions
  module Katello
    module Product
      class Update < Actions::EntryAction
        def plan(product, product_params)
          product.disable_auto_reindex!
          action_subject product
          product.update_attributes!(product_params)
          if product.previous_changes.key?('gpg_key_id')
            plan_action(::Actions::Katello::Product::RepositoriesGpgReset, product)
          end

          if ::Katello.config.use_cp && product.productContent_changed?
            plan_action(::Actions::Candlepin::Product::Update, product)
          end
          plan_action(::Actions::Pulp::Repos::Update, product) if ::Katello.config.use_pulp
          plan_action(ElasticSearch::Reindex, product) if ::Katello.config.use_elasticsearch
        end
      end
    end
  end
end
