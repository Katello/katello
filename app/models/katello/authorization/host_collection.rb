module Katello
  module Authorization::HostCollection
    extend ActiveSupport::Concern

    include Authorizable
    include Katello::Authorization

    def readable?
      authorized?(:view_host_collections)
    end

    def creatable?
      authorized?(:create_host_collections)
    end

    def editable?
      authorized?(:edit_host_collections)
    end

    def deletable?
      authorized?(:destroy_host_collections)
    end

    module ClassMethods
      def readable
        authorized(:view_host_collections)
      end

      def readable?
        User.current.can?(:view_host_collections)
      end

      def creatable
        authorized(:create_host_collections)
      end

      def editable
        authorized(:edit_host_collections)
      end

      def deletable
        authorized(:destroy_host_collections)
      end
    end
  end
end
