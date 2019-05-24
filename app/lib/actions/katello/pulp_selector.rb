module Actions
  module Katello
    module PulpSelector
      def plan_pulp_action(backend_actions, repository, smart_proxy, *args)
        found_action = select_pulp_action(backend_actions, repository, smart_proxy)
        fail "Could not locate an action for type #{backend_type}" unless found_action
        plan_action(found_action, repository, smart_proxy, *args)
      end

      private def select_pulp_action(backend_actions, repository, smart_proxy)
        backend_type = smart_proxy.backend_service_type(repository)
        found_action = backend_actions.find { |action| action.backend_service_type == backend_type }
        found_action
      end
    end
  end
end
