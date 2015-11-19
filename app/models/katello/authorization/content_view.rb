module Katello
  module Authorization::ContentView
    extend ActiveSupport::Concern

    include Authorizable

    def readable?
      authorized?(:view_content_views)
    end

    def editable?
      authorized?(:edit_content_views)
    end

    def deletable?
      authorized?(:destroy_content_views)
    end

    def publishable?
      authorized?(:publish_content_views)
    end

    def promotable_or_removable?
      authorized?(:promote_or_remove_content_views) && Katello::KTEnvironment.any_promotable?
    end

    module ClassMethods
      def readable
        authorized(:view_content_views)
      end

      def readable?
        ::User.current.can?(:view_content_views)
      end

      def editable
        authorized(:edit_content_views)
      end

      def deletable
        authorized(:destroy_content_views)
      end

      def deletable
        authorized(:publish_content_views)
      end

      def readable_repositories(repo_ids = nil)
        query = Katello::Repository.scoped
        content_views = Katello::ContentView.readable

        if repo_ids
          query.where(:id => repo_ids)
        else
          content_views = content_views.where(:default => false)
        end

        query.joins(:content_view_version)
             .where("#{Katello::ContentViewVersion.table_name}.content_view_id" => content_views.pluck(:id))
      end
    end
  end
end
