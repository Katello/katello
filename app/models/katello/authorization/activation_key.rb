module Katello
  module Authorization::ActivationKey
    extend ActiveSupport::Concern

    include Authorizable

    def readable?
      authorized?(:view_activation_keys)
    end

    def editable?
      authorized?(:edit_activation_keys)
    end

    def deletable?
      authorized?(:destroy_activation_keys)
    end

    module ClassMethods
      def readable
        authorized(:view_activation_keys)
      end

      def editable
        authorized(:edit_activation_keys)
      end

      def deletable
        authorized(:destroy_activation_keys)
      end

      def any_editable?
        editable.count > 0
      end

      def all_editable?(content_view, environments)
        key_query = ActivationKey.with_content_views(content_view).with_environments(environments)
        key_query.count == key_query.editable.count
      end
    end
  end
end
