module Actions
  module Katello
    module Host
      class Hypervisors < Actions::EntryAction
        def plan(environment, content_view, hypervisor_params)
          sequence do
            hypervisor_results = plan_action(::Actions::Candlepin::Consumer::Hypervisors, hypervisor_params)
            return if hypervisor_results.error

            plan_action(Katello::Host::HypervisorsUpdate, environment, content_view, hypervisor_results.output[:results])

            plan_self(:results => hypervisor_results.output[:results])
          end
        end

        def run
          output[:results] = input[:results]
        end
      end
    end
  end
end
