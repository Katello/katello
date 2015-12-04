module Actions
  module Candlepin
    module Consumer
      class Hypervisors < Candlepin::Abstract
        def plan(hypervisor_params)
          plan_self(:hypervisor_params => hypervisor_params)
        end

        def run
          output[:results] = ::Katello::Resources::Candlepin::Consumer.register_hypervisors(input[:hypervisor_params])
        end
      end
    end
  end
end
