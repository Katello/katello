module Actions
  module Katello
    class PulpSelector < Actions::Base
      middleware.use Actions::Middleware::PropagateOutput
      def plan(backend_actions, repository, smart_proxy, *args)
        return_action_output = args.dig(0, :return_output) || false
        found_action = PulpSelector.select(backend_actions, repository, smart_proxy)
        fail "Could not locate an action for type #{backend_type}" unless found_action
        if return_action_output
          sequence do
            action_output = plan_action(found_action, repository, smart_proxy, *args).output
            plan_self(:subaction_output => action_output)
          end
        else
          plan_action(found_action, repository, smart_proxy, *args)
        end
      end

      def run
        #Middleware propagates sub-action output to parent action.
      end

      def self.select(backend_actions, repository, smart_proxy)
        backend_type = smart_proxy.backend_service_type(repository)
        found_action = backend_actions.find { |action| action.backend_service_type == backend_type }
        found_action
      end
    end
  end
end
