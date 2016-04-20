module Actions
  module Candlepin
    module Owner
      class RefreshSubscriptions < Candlepin::AbstractAsyncTask
        input_format do
          param :label
        end

        def invoke_external_task
          ::Katello::Resources::Candlepin::Subscription.refresh_for_owner(input[:label])
        end
      end
    end
  end
end
