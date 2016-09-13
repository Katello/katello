module Actions
  module Katello
    module Host
      class Hypervisors < Actions::EntryAction
        def plan(hypervisor_params)
          sequence do
            hypervisor_results = ::Katello::Resources::Candlepin::Consumer.register_hypervisors(hypervisor_params)
            plan_action(Katello::Host::HypervisorsUpdate, parse_hypervisors(hypervisor_results))
          end
        end

        def parse_hypervisors(hypervisor_results)
          hypervisors = []
          %w(created updated unchanged).each do |group|
            if hypervisor_results[group]
              hypervisors += hypervisor_results[group].map do |hypervisor|
                {
                  :name => hypervisor['name'],
                  :uuid => hypervisor['uuid'],
                  :organization_label => hypervisor['owner']['key']
                }
              end
            end
          end
          hypervisors
        end
      end
    end
  end
end
