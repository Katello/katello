module Katello
  module Authorization::HostTracer
    extend ActiveSupport::Concern

    include Authorizable

    module ClassMethods
      def resolvable
        joins_authorized(::Host::Managed, :edit_hosts)
      end
    end
  end
end
