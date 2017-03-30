module Actions
  module Candlepin
    module Product
      class Create < Candlepin::Abstract
        input_format do
          param :name, String
          param :id
          param :multiplier
          param :attributes
          param :owner
        end

        def run
          output[:response] = ::Katello::Resources::Candlepin::Product.create(input[:owner], :name => input[:name],
                                                                              :id => input[:id],
                                                                              :multiplier => input[:multiplier],
                                                                              :attributes => input[:attributes])
        end
      end
    end
  end
end
