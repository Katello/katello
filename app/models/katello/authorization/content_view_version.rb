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
      def with_content_view_scope(scope)
        joins(:content_view).merge(Katello::ContentView.send(scope))
      end

      def readable
        with_content_view_scope(:readable)
      end

      def exportable
        with_content_view_scope(:exportable)
      end

      def editable
        with_content_view_scope(:editable)
      end

      def publishable
        with_content_view_scope(:publishable)
      end

      def deletable
        with_content_view_scope(:deletable)
      end

      def promotable_or_removable
        with_content_view_scope(:promotable_or_removable)
      end
    end
  end
end
