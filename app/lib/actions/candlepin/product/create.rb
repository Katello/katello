module Actions
  module Candlepin
    module Product
      class Create < Candlepin::Abstract
        input_format do
          param :name, String
          param :multiplier
          param :attributes
          param :owner
        end

        def run
          output[:response] = ::Katello::Resources::Candlepin::Product.create(input[:owner], :name => input[:name],
                                                                              :id => unused_product_id,
                                                                              :multiplier => input[:multiplier],
                                                                              :attributes => input[:attributes])
        end

        def unused_product_id
          id = SecureRandom.random_number(999_999_999_999)
          if ::Katello::Product.find_by(:cp_id => id)
            unused_product_id
          else
            id
          end
        end
      end
    end
  end
end
