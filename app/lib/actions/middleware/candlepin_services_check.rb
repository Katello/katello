module Actions
  module Middleware
    class CandlepinServicesCheck < BackendServicesCheck
      def services
        [:candlepin, :candlepin_auth]
      end
    end
  end
end
