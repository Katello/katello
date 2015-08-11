load File.expand_path('../widget.rb', __FILE__)

module Katello
  class Dashboard::ErrataWidget < Dashboard::Widget
    def accessible?
      User.current.admin? ||
       (current_organization &&
        User.current.allowed_organizations.include?(current_organization) &&
        System.readable?)
    end

    def title
      _("Errata Overview")
    end

    def content_path
      errata_dashboard_index_path
    end
  end
end
