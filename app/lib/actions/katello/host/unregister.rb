module Actions
  module Katello
    module Host
      class Unregister < Actions::EntryAction
        middleware.use ::Actions::Middleware::RemoteAction

        def plan(host, options = {})
          plan_action(Katello::Host::Destroy, host, options.merge(:destroy_object => false, :destroy_aspects => false))
        end

        def humanized_name
          _("Unregister Host")
        end
      end
    end
  end
end
