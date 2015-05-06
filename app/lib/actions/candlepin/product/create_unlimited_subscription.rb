module Actions
  module Candlepin
    module Product
      class CreateUnlimitedSubscription < Candlepin::Abstract
        input_format do
          param :owner_key, String
          param :product_id, String
        end

        def run
          output[:response] = ::Katello::Resources::Candlepin::Product.create_unlimited_subscription(input[:owner_key],
                                                                                                     input[:product_id])
        end
      end
    end
  end
end
