module Actions
  module Middleware
    class Pulp3ServicesCheck < BackendServicesCheck
      def services
        [:pulp3]
      end
    end
  end
end
