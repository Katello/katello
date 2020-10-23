module Katello
  module Authorization::ContentViewComponent
    extend ActiveSupport::Concern

    module ClassMethods
      def readable
        where(:composite_content_view_id => ::Katello::ContentView.readable)
      end

      def editable
        where(:composite_content_view_id => ::Katello::ContentView.editable)
      end
    end
  end
end
