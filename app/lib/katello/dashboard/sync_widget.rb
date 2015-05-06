module Katello
  class Dashboard::SyncWidget < Dashboard::Widget
    def accessible?
      User.current.admin? ||
       (current_organization &&
        User.current.allowed_organizations.include?(current_organization) &&
        Product.syncable?)
    end

    def title
      _("Sync Overview")
    end

    def content_path
      sync_dashboard_index_path
    end
  end
end
