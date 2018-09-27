module Actions
  module Katello
    module Product
      class ContentDestroy < Actions::Base
        def plan(root_repository)
          fail _("Cannot delete redhat product content") if root_repository.product.redhat?
          sequence do
            plan_action(Candlepin::Product::ContentRemove,
                        owner: root_repository.product.organization.label,
                        product_id: root_repository.product.cp_id,
                        content_id: root_repository.content_id)

            katello_content_id = root_repository.content_id
            ::Katello::ProductContent.where(product_id: root_repository.product_id,
                                            content_id: katello_content_id).destroy_all

            if root_repository.repositories.count <= 1
              plan_action(Candlepin::Product::ContentDestroy,
                          owner: root_repository.product.organization.label,
                          content_id: root_repository.content_id)

              ::Katello::Content.find(katello_content_id).destroy!
            end
          end
        end
      end
    end
  end
end
