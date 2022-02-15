module Actions
  module Pulp3
    class Abstract < Actions::EntryAction
      middleware.use ::Actions::Middleware::RemoteAction
      middleware.use Actions::Middleware::Pulp3ServicesCheck

      BACKEND_SERVICE_TYPE = 'pulp3'.freeze

      def self.backend_service_type
        BACKEND_SERVICE_TYPE
      end

      def smart_proxy
        SmartProxy.unscoped.find(input[:smart_proxy_id])
      end
    end
  end
end
