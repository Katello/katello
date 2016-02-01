module Actions
  module Candlepin
    module Consumer
      class RemoveSubscription < Candlepin::Abstract
        middleware.use Actions::Middleware::KeepCurrentUser

        input_format do
          param :uuid, String
          param :entitlement_id, String
        end

        def run
          ::Katello::Resources::Candlepin::Consumer.remove_entitlement(input[:uuid], input[:entitlement_id])
        end
      end
    end
  end
end
