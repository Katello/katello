module Actions
  module Candlepin
    module Product
      class Update < Candlepin::Abstract
        input_format do
          param :owner
          param :name
          param :id
        end

        def run
          output[:response] = ::Katello::Resources::Candlepin::Product.update(input[:owner], name: input[:name], id: input[:id])
        end
      end
    end
  end
end
