module Actions
  module Katello
    class PulpSelector < Actions::Base
      include Helpers::Presenter
      def plan(backend_actions, repository, smart_proxy, *args)
        pass_only_args = args.dig(0, :args_only) || false
        return_action_output = args.dig(0, :return_output) || false
        backend_type = smart_proxy.backend_service_type(repository)
        found_action = backend_actions.find { |action| action.backend_service_type == backend_type }

        fail "Could not locate an action for type #{backend_type}" unless found_action
        if return_action_output
          sequence do
            action_output = pass_only_args ? plan_action(found_action, *args).output : plan_action(found_action, repository, smart_proxy, *args).output
            plan_self(:output => action_output)
          end
        else
          planned_action = pass_only_args ? plan_action(found_action, *args) : plan_action(found_action, repository, smart_proxy, *args)
        end
      end

      def run
        input[:output].each do |key, value|
          output[key] = value
        end
      end

      def presenter
        Helpers::Presenter::Delegated.new(self, planned_actions(Pulp::Orchestration::Repository::Sync))
      end

    end
  end
end

