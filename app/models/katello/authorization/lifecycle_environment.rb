module Katello
  module Authorization::LifecycleEnvironment
    extend ActiveSupport::Concern

    include Authorizable

    def readable?
      authorized?(:view_lifecycle_environments)
    end

    def creatable?
      self.class.creatable?
    end

    def editable?
      authorized?(:edit_lifecycle_environments)
    end

    def deletable?
      authorized?(:destroy_lifecycle_environments)
    end

    module ClassMethods
      def readable
        authorized(:view_lifecycle_environments)
      end

      def promotable
        authorized(:promote_or_remove_content_views)
      end

      def promotable?
        User.current.can?(:promote_or_remove_content_views)
      end

      def any_promotable?
        promotable.count > 0
      end

      def creatable?
        ::User.current.can?(:create_lifecycle_environments)
      end

      def content_readable(org)
        readable.where(:organization_id => org)
      end
    end
  end
end
