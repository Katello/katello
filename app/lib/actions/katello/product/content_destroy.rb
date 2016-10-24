module Actions
  module Katello
    module Product
      class ContentDestroy < Actions::Base
        def plan(repository)
          fail _("Cannot delete redhat product content") if repository.product.redhat?
          sequence do
            plan_action(Candlepin::Product::ContentRemove,
                        owner: repository.product.organization.label,
                        product_id: repository.product.cp_id,
                        content_id: repository.content_id)
            if repository.other_repos_with_same_content.empty?
              plan_action(Candlepin::Product::ContentDestroy,
                          owner: repository.product.organization.label,
                          content_id: repository.content_id)
            end
          end
        end
      end
    end
  end
end
