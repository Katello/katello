module Actions
  module Katello
    module Product
      class ReindexSubscriptions < Actions::EntryAction
        middleware.use Actions::Middleware::KeepCurrentUser

        input_format do
          param :id
          param :subscription_id
        end

        def plan(product, subscription_id)
          fail "Only custom products supported." if product.redhat?
          Type! product, ::Katello::Product
          plan_self(id: product.id, subscription_id: subscription_id)
        end

        def run
          product = ::Katello::Product.find_by!(:id => input[:id])
          product.import_subscription(input[:subscription_id])
        end
      end
    end
  end
end
