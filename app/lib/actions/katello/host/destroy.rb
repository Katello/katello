module Actions
  module Katello
    module Host
      class Destroy < Actions::EntryAction
        middleware.use ::Actions::Middleware::RemoteAction

        def plan(host, options = {})
          action_subject(host)
          ::Katello::RegistrationManager.unregister_host(host, options)
        end

        def humanized_name
          _("Destroy Content Host")
        end
      end
    end
  end
end
