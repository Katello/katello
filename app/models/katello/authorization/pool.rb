module Katello
  module Authorization::Pool
    extend ActiveSupport::Concern

    module ClassMethods
      def readable
        where(:subscription_id => Katello::Subscription.authorized(:view_subscriptions))
      end
    end
  end
end
