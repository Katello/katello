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
        view_ids = ::Katello::ContentView.readable.collect { |v| v.id }
        joins(:content_view).where("#{Katello::ContentView.table_name}.id" => view_ids)
      end
    end
  end
end
