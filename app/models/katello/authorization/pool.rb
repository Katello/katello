module Katello
  module Authorization::Pool
    extend ActiveSupport::Concern

    include Authorizable

    module ClassMethods
      def readable
        where(:subscription_id => Katello::Subscription.authorized(:view_subscriptions))
      end
    end
  end
end
