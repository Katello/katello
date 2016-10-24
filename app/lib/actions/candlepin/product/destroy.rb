module Actions
  module Candlepin
    module Product
      class Destroy < Candlepin::Abstract
        input_format do
          param :cp_id
          param :owner
        end

        def run
          output[:response] = ::Katello::Resources::Candlepin::Product.destroy(input[:owner], input[:cp_id])
        end
      end
    end
  end
end
