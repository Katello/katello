module Actions
  module Katello
    module Host
      class Hypervisors < Actions::EntryAction
        def queue
          ::Katello::HOST_TASKS_QUEUE
        end

        def plan(hypervisor_params, options = {})
          task_id = options.fetch(:task_id, nil)
          sequence do
            if task_id
              task_output = plan_action(Candlepin::AsyncHypervisors, :task_id => task_id).output
              parsed_response = task_output[:hypervisors]
            elsif hypervisor_params
              hypervisor_results = ::Katello::Resources::Candlepin::Consumer.register_hypervisors(hypervisor_params)
              parsed_response = Hypervisors.parse_hypervisors(hypervisor_results)
            end
            plan_self(:hypervisors => parsed_response)
            plan_action(Katello::Host::HypervisorsUpdate, :hypervisors => parsed_response)
          end
        end

        def self.parse_hypervisors(hypervisor_results)
          hypervisors = []
          %w(created updated unchanged).each do |group|
            if hypervisor_results[group]
              hypervisors += hypervisor_results[group].map do |hypervisor|
                {
                  :name => hypervisor['name'],
                  :uuid => hypervisor['uuid'],
                  :organization_label => hypervisor['owner']['key'],
                }
              end
            end
          end
          hypervisors
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end
      end
    end
  end
end
