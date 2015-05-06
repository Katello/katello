module Katello
  module Authorization::System
    extend ActiveSupport::Concern

    include Authorizable
    include Katello::Authorization

    def readable?
      authorized?(:view_content_hosts)
    end

    def editable?
      authorized?(:edit_content_hosts)
    end

    def deletable?
      authorized?(:destroy_content_hosts)
    end

    module ClassMethods
      def readable_search_filters(_org)
        {:or => [
          {:terms => {:environment_id => KTEnvironment.readable.pluck(:id) }}
        ]
        }
      end

      def readable
        authorized(:view_content_hosts)
      end

      def readable?
        User.current.can?(:view_content_hosts)
      end

      def editable
        authorized(:edit_content_hosts)
      end

      def deletable
        authorized(:destroy_content_hosts)
      end

      def any_editable?
        authorized(:edit_content_hosts).count > 0
      end

      def all_editable?(content_view, environments)
        systems_query = System.where(:content_view_id => content_view, :environment_id => environments)
        systems_query.count == systems_query.editable.count
      end
    end
  end
end
