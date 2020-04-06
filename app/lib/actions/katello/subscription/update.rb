module Actions
  module Katello
    module Subscription
      class Update < Actions::EntryAction
        def plan(subscription, subscription_params)
          subscription.update!(subscription_params)
        end
      end
    end
  end
end
