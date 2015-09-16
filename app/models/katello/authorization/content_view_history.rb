module Katello
  module Authorization::ContentViewHistory
    extend ActiveSupport::Concern
    include Authorizable

    module ClassMethods
      def readable
        where(:katello_content_view_version_id => Katello::ContentViewVersion.readable)
      end
    end
  end
end
