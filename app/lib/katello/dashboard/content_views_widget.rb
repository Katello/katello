module Katello
  class Dashboard::ContentViewsWidget < Dashboard::Widget
    def accessible?
      User.current.admin? ||
       (current_organization &&
        User.current.allowed_organizations.include?(current_organization) &&
        ContentView.readable?)
    end

    def title
      _("Content Views Overview")
    end

    def content_path
      content_views_dashboard_index_path
    end
  end
end
