module Katello
  module Authorization::ContentViewVersionExportHistory
    extend ActiveSupport::Concern

    module ClassMethods
      def readable
        where(:content_view_version_id => Katello::ContentViewVersion.readable)
      end
    end
  end
end
