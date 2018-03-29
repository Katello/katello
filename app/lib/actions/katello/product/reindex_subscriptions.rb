module Actions
  module Katello
    module Product
      class ReindexSubscriptions < Actions::EntryAction
        middleware.use Actions::Middleware::KeepCurrentUser

        input_format do
          param :id
        end

        def plan(product)
          fail "Only custom products supported." if product.redhat?
          Type! product, ::Katello::Product
          plan_self(id: product.id)
        end

        def run
          product = ::Katello::Product.find_by!(:id => input[:id])
          product.import_custom_subscription
        end
      end
    end
  end
end
