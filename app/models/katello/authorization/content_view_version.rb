module Katello
  module Authorization::ContentViewVersion
    extend ActiveSupport::Concern

    module ClassMethods
      def readable
        view_ids = ContentView.readable.collect { |v| v.id }
        joins(:content_view).where("#{Katello::ContentView.table_name}.id" => view_ids)
      end
    end
  end
end
