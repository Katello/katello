module Actions
  module Pulp
    class Abstract < Actions::Base
      middleware.use ::Actions::Middleware::RemoteAction
      middleware.use Actions::Middleware::PulpServicesCheck

      def pulp_resources(capsule_id = nil)
        capsule_id ||= input["capsule_id"]
        if capsule_id
          capsule_content = ::Katello::CapsuleContent.new(SmartProxy.unscoped.find(capsule_id))
          capsule_content.pulp_server.resources
        else
          ::Katello.pulp_server.resources
        end
      end

      def pulp_extensions(capsule_id = nil)
        capsule_id ||= input["capsule_id"]
        if capsule_id
          capsule_content = ::Katello::CapsuleContent.new(SmartProxy.unscoped.find(capsule_id))
          capsule_content.pulp_server.extensions
        else
          ::Katello.pulp_server.extensions
        end
      end
    end
  end
end
