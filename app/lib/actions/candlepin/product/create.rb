module Actions
  module Candlepin
    module Product
      class Create < Candlepin::Abstract
        input_format do
          param :name, String
          param :multiplier
          param :attributes
        end

        def run
          output[:response] = ::Katello::Resources::Candlepin::Product.create(:name => input[:name],
                                                                              :multiplier => input[:multiplier],
                                                                              :attributes => input[:attributes])
        end
      end
    end
  end
end
