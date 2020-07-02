module Actions
  module Candlepin
    module Product
      class ContentUpdateEnablement < Candlepin::Abstract
        input_format do
          param :content_enablements
          param :owner
          param :product_id
        end

        def run
          output[:response] = ::Katello::Resources::Candlepin::Product.
              update_enabled(input[:owner], input[:product_id], input[:content_enablements])
        end
      end
    end
  end
end
