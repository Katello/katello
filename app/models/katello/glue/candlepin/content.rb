module Katello
  module Glue
    module Candlepin
      module Content
        extend ActiveSupport::Concern

        def modified_product_ids(org)
          @modified_product_cache ||= {}
          return @modified_product_cache[org.label] if @modified_product_cache[org.label]
          result = Resources::Candlepin::Content.get(org.label, self.cp_content_id)
          @modified_product_cache[org.label] = result['modifiedProductIds']
        end
      end
    end
  end
end
