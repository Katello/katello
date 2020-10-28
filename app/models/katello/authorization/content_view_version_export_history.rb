module Katello
  module Authorization::ContentViewVersionExportHistory
    extend ActiveSupport::Concern

    module ClassMethods
      def readable
        joins(:content_view_version).merge(Katello::ContentViewVersion.readable)
      end
    end
  end
end
