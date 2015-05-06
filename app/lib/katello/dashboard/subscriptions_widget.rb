module Katello
  class Dashboard::SubscriptionsWidget < Dashboard::Widget
    def accessible?
      User.current.admin? ||
       (current_organization &&
        current_organization.subscriptions_readable?)
    end

    def title
      _("Content Host Subscription Status")
    end
  end
end
