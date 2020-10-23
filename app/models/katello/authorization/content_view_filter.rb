module Katello
  module Authorization::ContentViewFilter
    extend ActiveSupport::Concern

    module ClassMethods
      def readable
        where(:content_view_id => ::Katello::ContentView.readable)
      end

      def editable
        where(:content_view_id => ::Katello::ContentView.editable)
      end
    end
  end
end
