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

            katello_content_id = repository.product.product_content_by_id(repository.content_id).content_id

            ::Katello::ProductContent.where(product_id: repository.product_id,
                                            content_id: katello_content_id).destroy_all

            if repository.other_repos_with_same_content.empty?
              plan_action(Candlepin::Product::ContentDestroy,
                          owner: repository.product.organization.label,
                          content_id: repository.content_id)

              ::Katello::Content.find(katello_content_id).destroy!
            end
          end
        end
      end
    end
  end
end
