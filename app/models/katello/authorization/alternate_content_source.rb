module Katello
  module Authorization::AlternateContentSource
    extend ActiveSupport::Concern

    include Authorizable

    def readable?
      authorized?(:view_alternate_content_sources)
    end

    def editable?
      authorized?(:edit_alternate_content_sources)
    end

    def deletable?
      authorized?(:destroy_alternate_content_sources)
    end

    module ClassMethods
      def readable
        authorized(:view_alternate_content_sources)
      end

      def editable
        authorized(:edit_alternate_content_sources)
      end

      def deletable
        authorized(:destroy_alternate_content_sources)
      end
    end
  end
end
