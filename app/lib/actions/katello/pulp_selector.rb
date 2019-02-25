module Actions
  module Katello
    class PulpSelector < Actions::Base
      def plan(pulp2_action, pulp3_action, repository, smart_proxy, *args)
        if smart_proxy.pulp3_support?(repository)
          plan_action(pulp3_action, repository, smart_proxy, *args)
        else
          plan_action(pulp2_action, repository, smart_proxy, *args)
        end
      end
    end
  end
end
