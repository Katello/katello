module Actions
  module Katello
    module PulpSelector
      def plan_optional_pulp_action(backend_actions, repository, smart_proxy, *args)
        found_action = select_pulp_action(backend_actions, repository, smart_proxy)
        plan_action(found_action, repository, smart_proxy, *args) if found_action
      end

      def select_pulp_action(backend_actions, repository, smart_proxy)
        backend_type = smart_proxy.backend_service_type(repository)
        found_action = backend_actions.find { |action| action.backend_service_type == backend_type }
        found_action
      end
    end
  end
end
