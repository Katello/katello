module Actions
  module Candlepin
    module Consumer
      class RemoveSubscription < Candlepin::Abstract
        middleware.use Actions::Middleware::KeepCurrentUser

        input_format do
          param :uuid, String
          param :entitlement_id, String
          param :pool_id, String
        end

        def run
          ::Katello::Resources::Candlepin::Consumer.remove_entitlement(input[:uuid], input[:entitlement_id])
        end

        def finalize
          pool = ::Katello::Pool.where(:cp_id => input[:pool_id]).first
          pool.import_data if pool
        end
      end
    end
  end
end
