module Actions
  module Candlepin
    module Product
      class DeleteSubscriptions < Candlepin::AbstractAsyncTask
        input_format do
          param :organization_label
          param :cp_id
        end

        def invoke_external_task
          output[:response] = ::Katello::Resources::Candlepin::Product.delete_subscriptions(input[:organization_label], input[:cp_id])
        end
      end
    end
  end
end
