module Katello
  module Glue::Candlepin::ProductContent
    def self.included(base)
      base.send :include, InstanceMethods
    end

    module InstanceMethods
      def modified_product_ids
        return @modified_product_ids if @modified_product_ids
        result = Resources::Candlepin::Content.get(self.product.organization.label, self.cp_content_id)
        @modified_product_ids = result['modifiedProductIds']
      end
    end
  end
end
