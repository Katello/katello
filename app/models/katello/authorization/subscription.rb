module Katello
  module Authorization::Subscription
    extend ActiveSupport::Concern

    include Authorizable

    def readable?
      authorized?(:view_subscriptions)
    end

    module ClassMethods
      def readable
        return all if User.current.admin?

        authorized(:view_subscriptions).where(organization_id: User.current.organization_ids)
      end
    end
  end
end
