module Katello
  module Authorization::GpgKey
    extend ActiveSupport::Concern

    include Authorizable

    def readable?
      authorized?(:view_content_credentials)
    end

    def editable?
      authorized?(:edit_content_credentials)
    end

    def deletable?
      authorized?(:destroy_content_credentials)
    end

    module ClassMethods
      def readable
        authorized(:view_content_credentials)
      end

      def editable
        authorized(:edit_content_credentials)
      end

      def deletable
        authorized(:destroy_content_credentials)
      end
    end
  end
end
