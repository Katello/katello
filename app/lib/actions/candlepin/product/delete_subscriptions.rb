module Actions
  module Candlepin
    module Product
      class DeleteSubscriptions < Candlepin::Abstract
        input_format do
          param :organization_label
          param :cp_id
        end

        def run
          ::Katello::Resources::Candlepin::Product.delete_subscriptions(input[:organization_label], input[:cp_id])
        end
      end
    end
  end
end
