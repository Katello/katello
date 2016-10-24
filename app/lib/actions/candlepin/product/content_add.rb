module Actions
  module Candlepin
    module Product
      class ContentAdd < Candlepin::Abstract
        input_format do
          param :product_id
          param :content_id
          param :owner
        end

        def run
          output[:response] = ::Katello::Resources::Candlepin::Product.
              add_content(input[:owner], input[:product_id], input[:content_id], true)
        end
      end
    end
  end
end
