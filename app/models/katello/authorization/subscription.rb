module Katello
  module Authorization::Subscription
    extend ActiveSupport::Concern

    include Authorizable

    def readable?
      authorized?(:view_subscriptions)
    end

    module ClassMethods
      def readable
        authorized(:view_subscriptions)
      end
    end
  end
end
