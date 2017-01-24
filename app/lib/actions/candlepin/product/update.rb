module Actions
  module Candlepin
    module Product
      class Update < Candlepin::Abstract
        def plan(product)
          product.deleted_content.each do |product_content|
            plan_action(::Actions::Candlepin::Product::ContentRemove,
                        :owner => product.organization.label,
                        :product_id => product.cp_id,
                        :content_id => product_content.content.id)
            plan_action(::Actions::Candlepin::Product::ContentDestroy,
                        :owner => product.organization.label,
                        :content_id => product_content.content.id)
          end

          product.added_content.each do |pc|
            content_create = plan_action(::Actions::Candlepin::Product::ContentCreate,
                                         :owner => product.organization.label,
                                         :name => pc.content.name,
                                         :type => pc.content.type,
                                         :label => pc.content.label,
                                         :content_url => pc.content.contentUrl)
            plan_action(::Actions::Candlepin::Product::ContentAdd,
                        :owner => product.organization.label,
                        :product_id => product.cp_id,
                        :content_id => content_create.output[:response][:id])
          end
        end
      end
    end
  end
end
