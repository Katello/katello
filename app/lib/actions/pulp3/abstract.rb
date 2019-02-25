module Actions
  module Pulp3
    class Abstract < Actions::Base
      middleware.use ::Actions::Middleware::RemoteAction

      def smart_proxy
        SmartProxy.find(input[:smart_proxy_id])
      end
    end
  end
end
