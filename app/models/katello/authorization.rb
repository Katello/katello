# TODO: Remove this module and all inclusions of it in models
# once this is added to Foreman core https://github.com/theforeman/foreman/pull/1384
module Katello
  module Authorization
    extend ActiveSupport::Concern

    included do
      def authorized?(permission)
        ::User.current.can?(permission, self)
      end
    end
  end
end
