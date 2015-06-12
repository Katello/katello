module Katello
  class Dashboard::TasksSummaryWidget < Dashboard::Widget
    def accessible?
      User.current.admin? ||
       (current_organization &&
        current_organization.subscriptions_readable?)
    end

    def title
      _("Tasks Summary")
    end
  end
end
