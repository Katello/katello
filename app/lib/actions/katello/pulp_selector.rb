module Actions
  module Katello
    class PulpSelector < Actions::Base
      def plan(backend_actions, repository, smart_proxy, *args)
        backend_type = smart_proxy.backend_service_type(repository)
        found_action = backend_actions.find { |action| action.backend_service_type == backend_type }

        fail "Could not locate an action for type #{backend_type}" unless found_action
        plan_action(found_action, repository, smart_proxy, *args)
      end
    end
  end
end
