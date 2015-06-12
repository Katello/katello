module Katello
  class Dashboard::ErrorWarningTasksWidget < Dashboard::Widget
    def accessible?
      User.current.admin? ||
       (current_organization &&
        User.current.allowed_organizations.include?(current_organization) &&
        HostCollection.readable?)
    end

    def title
      _("Tasks in Warning/Error")
    end
  end
end
