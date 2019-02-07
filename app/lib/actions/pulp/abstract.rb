module Actions
  module Pulp
    class Abstract < Actions::Base
      middleware.use ::Actions::Middleware::RemoteAction
      middleware.use Actions::Middleware::PulpServicesCheck

      def pulp_resources(capsule_id = nil)
        capsule_content(capsule_id).resources
      end

      def pulp_extensions(capsule_id = nil)
        capsule_content(capsule_id).extensions
      end

      def smart_proxy(id)
        SmartProxy.unscoped.find(id)
      end

      private

      def capsule_content(capsule_id = nil)
        capsule_id ||= input["capsule_id"]
        if capsule_id
          SmartProxy.unscoped.find(capsule_id).pulp_api
        else
          ::Katello.pulp_server
        end
      end
    end
  end
end
