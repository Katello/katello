module Actions
  module Candlepin
    module Consumer
      class AttachSubscription < Candlepin::Abstract
        middleware.use Actions::Middleware::KeepCurrentUser

        input_format do
          param :uuid, String
          param :pool_uuid, String
          param :quantity, Integer
        end

        def run
          ::Katello::Resources::Candlepin::Consumer.consume_entitlement(input[:uuid], input[:pool_uuid], input[:quantity])
        end
      end
    end
  end
end
