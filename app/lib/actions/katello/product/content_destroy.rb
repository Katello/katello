module Actions
  module Katello
    module Product
      class ContentDestroy < Actions::Base
        def plan(repository)
          root_repository = repository.root
          fail _("Cannot delete redhat product content") if root_repository.product.redhat?
          sequence do
            plan_action(Candlepin::Product::ContentRemove,
                        owner: root_repository.product.organization.label,
                        product_id: root_repository.product.cp_id,
                        content_id: repository.content_id)

            katello_content_id = repository.content&.id
            ::Katello::ProductContent.where(product_id: root_repository.product_id,
                                            content_id: katello_content_id).destroy_all

            if root_repository.repositories.count <= 1 || repository.deb_using_structured_apt?
              plan_action(Candlepin::Product::ContentDestroy,
                          owner: root_repository.product.organization.label,
                          content_id: repository.content_id)

              ::Katello::Content.find_by_id(katello_content_id)&.destroy!
            end
          end
        end
      end
    end
  end
end
