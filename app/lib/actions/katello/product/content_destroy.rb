module Actions
  module Katello
    module Product
      class ContentDestroy < Actions::Base
        def plan(repository)
          if !repository.product.provider.redhat_provider? &&
               repository.other_repos_with_same_product_and_content.empty?
            sequence do
              plan_action(Candlepin::Product::ContentRemove,
                          product_id: repository.product.cp_id,
                          content_id: repository.content_id)
              if repository.other_repos_with_same_content.empty?
                plan_action(Candlepin::Product::ContentDestroy,
                            content_id: repository.content_id)
              end
            end
          end
        end
      end
    end
  end
end
