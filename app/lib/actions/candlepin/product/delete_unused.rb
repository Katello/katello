module Actions
  module Candlepin
    module Product
      class DeleteUnused < Candlepin::Abstract
        def plan(organization)
          organization.products.each do |product|
            plan_action(Candlepin::Product::Destroy, cp_id: product.cp_id) unless product.used_by_another_org?
          end
        end
      end
    end
  end
end
