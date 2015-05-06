module Actions
  module Pulp
    class Abstract < Actions::Base
      middleware.use ::Actions::Middleware::RemoteAction

      def pulp_resources
        ::Katello.pulp_server.resources
      end

      def pulp_extensions
        ::Katello.pulp_server.extensions
      end
    end
  end
end
