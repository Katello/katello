module Actions
  module Katello
    class PulpSelector < Actions::Base
      include Actions::Helpers::OutputPropagator
      def plan(backend_actions, repository, smart_proxy, *args)
        found_action = PulpSelector.select(backend_actions, repository, smart_proxy)
        fail "Could not locate an action for type #{backend_type}" unless found_action
        sequence do
          action = plan_action(found_action, repository, smart_proxy, *args)
          if found_action.included_modules.include? Actions::Helpers::OutputPropagator
            action_output = action.output
            plan_self(:subaction_output => action_output)
          else
            plan_self
          end
        end
      end

      def self.select(backend_actions, repository, smart_proxy)
        backend_type = smart_proxy.backend_service_type(repository)
        found_action = backend_actions.find { |action| action.backend_service_type == backend_type }
        found_action
      end
    end
  end
end
