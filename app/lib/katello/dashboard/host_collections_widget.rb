module Katello
  class Dashboard::HostCollectionsWidget < Dashboard::Widget
    def accessible?
      User.current.admin? ||
       (current_organization &&
        User.current.allowed_organizations.include?(current_organization) &&
        HostCollection.readable?)
    end

    def title
      _("Host Collections")
    end

    def content_path
      host_collections_dashboard_index_path
    end
  end
end
