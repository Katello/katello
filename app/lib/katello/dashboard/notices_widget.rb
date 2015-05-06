module Katello
  class Dashboard::NoticesWidget < Dashboard::Widget
    def title
      _("Latest Notifications")
    end

    def content_path
      notices_dashboard_index_path
    end
  end
end
