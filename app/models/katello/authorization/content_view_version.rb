module Katello
  module Authorization::ContentViewVersion
    extend ActiveSupport::Concern

    def all_hosts_editable?(lifecycle_environment)
      total_hosts = ::Host.in_content_view_environment(:content_view => self.content_view, :lifecycle_environment => lifecycle_environment)
      authorized_hosts = ::Host.authorized("view_hosts").in_content_view_environment(:content_view => self.content_view,
                                                                                     :lifecycle_environment => lifecycle_environment)
      total_hosts.count == authorized_hosts.count
    end

    module ClassMethods
      def readable
        joins(:content_view).merge(::Katello::ContentView.readable)
      end

      def exportable
        joins(:content_view).merge(::Katello::ContentView.exportable)
      end
    end
  end
end
