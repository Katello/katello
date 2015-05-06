module Katello
  class Dashboard::SubscriptionsTotalsWidget < Dashboard::Widget
    def accessible?
      User.current.admin? ||
       (current_organization &&
        current_organization.subscriptions_readable?)
    end

    def title
      _("Current Subscription Totals")
    end

    def content_path
      subscriptions_totals_dashboard_index_path
    end
  end
end
