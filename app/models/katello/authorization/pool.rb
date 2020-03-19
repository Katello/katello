module Katello
  module Authorization::Pool
    extend ActiveSupport::Concern

    include Authorizable

    def readable?
      self.class.readable.where(id: self.id).any?
    end

    module ClassMethods
      def readable
        relation = joins_authorized(Katello::Subscription, :view_subscriptions)
        relation = relation.where(organization_id: User.current.organization_ids) unless User.current.admin?
        relation
      end
    end
  end
end
