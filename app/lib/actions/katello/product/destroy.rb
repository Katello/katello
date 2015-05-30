module Actions
  module Katello
    module Product
      class Destroy < Actions::EntryAction
        # rubocop:disable MethodLength
        def plan(product, options = {})
          organization_destroy = options.fetch(:organization_destroy, false)

          unless organization_destroy || product.user_deletable?
            fail _("Cannot delete a Red Hat Products or Products with Repositories published in a Content View")
          end

          action_subject(product)

          sequence do
            unless organization_destroy
              concurrence do
                product.repositories.in_default_view.each do |repo|
                  repo_options = options.clone
                  repo_options[:planned_destroy] = true
                  plan_action(Katello::Repository::Destroy, repo, repo_options)
                end
              end
              concurrence do
                plan_action(Candlepin::Product::DeletePools,
                              cp_id: product.cp_id, organization_label: product.organization.label)
                plan_action(Candlepin::Product::DeleteSubscriptions,
                              cp_id: product.cp_id, organization_label: product.organization.label)
              end
            end

            if !product.used_by_another_org? && !organization_destroy
              if product.is_a? ::Katello::MarketingProduct
                concurrence do
                  product.productContent.each do |pc|
                    plan_action(Candlepin::Product::ContentRemove,
                                product_id: product.cp_id,
                                content_id: pc.content.id)
                  end
                end
              end

              plan_action(Candlepin::Product::Destroy, cp_id: product.cp_id)
            end

            plan_self(:product_id => product.id)
            plan_action(ElasticSearch::Provider::ReindexSubscriptions, product.provider) unless organization_destroy
          end
        end

        def finalize
          product = ::Katello::Product.find(input[:product_id])
          product.destroy!
        end

        def humanized_name
          _("Delete Product")
        end
      end
    end
  end
end
