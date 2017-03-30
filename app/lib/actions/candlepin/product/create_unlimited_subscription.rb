module Actions
  module Candlepin
    module Product
      class CreateUnlimitedSubscription < Candlepin::Abstract
        input_format do
          param :owner_key, String
          param :product_id, String
          param :start_time, Time
        end

        def run
          if input[:start_time]
            start_time = Time.iso8601(input[:start_time])
          else
            start_time = nil
          end
          output[:response] = ::Katello::Resources::Candlepin::Product.create_unlimited_subscription(input[:owner_key],
                                                                                                     input[:product_id],
                                                                                                     start_time)
        end
      end
    end
  end
end
