module Actions
  module Middleware
    class ElasticsearchServicesCheck < BackendServicesCheck
      def services
        [:elasticsearch]
      end
    end
  end
end
