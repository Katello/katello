module Actions
  module Middleware
    class PulpServicesCheck < BackendServicesCheck
      def services
        [:pulp, :pulp_auth]
      end
    end
  end
end
