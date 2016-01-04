module Actions
  module Katello
    module System
      class Destroy < Actions::EntryAction
        middleware.use ::Actions::Middleware::RemoteAction

        def plan(system, options = {})
          plan_action(Katello::Host::Destroy, system.foreman_host, options)
        end

        def humanized_name
          _("Destroy Content Host")
        end
      end
    end
  end
end
