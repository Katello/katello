module Actions
  module Candlepin
    module Product
      class Destroy < Candlepin::Abstract
        input_format do
          param :cp_id
        end

        def run
          output[:response] = ::Katello::Resources::Candlepin::Product.destroy(input[:cp_id])
        end
      end
    end
  end
end
