module Katello
  module Authorization::HostTracer
    extend ActiveSupport::Concern

    include Authorizable

    module ClassMethods
      def resolvable
        relation = joins_authorized(::Host::Managed, :edit_hosts)
        relation
      end
    end
  end
end
