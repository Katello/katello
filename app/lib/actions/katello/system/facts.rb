module Actions
  module Katello
    module System
      class Facts < Actions::EntryAction
        def plan(system)
          plan_self(:system => system, :host => system.foreman_host.id, :facts => system.facts)
        end

        def run
          host = Host.find(input[:host])

          input[:facts].each do |fact_name, fact_value|
            fact = ::Katello::FactName.where(:name => fact_name).first
            if fact.nil?
              fact = ::Katello::FactName.new(:name => fact_name)
              fact.save
            end
            host_facts = host.facts
            if host_facts[fact_name]
              fact.update_attribute(:value, fact_value)
            else
              host.fact_values.create!(:fact_name_id => fact.id, :value => fact_value)
            end
          end

          fact_name = "something"
          fact_value = input[:host]
          fact = ::Katello::FactName.where(:name => fact_name).first
          if fact.nil?
            fact = ::Katello::FactName.new(:name => fact_name)
            fact.save
          end
          host.fact_values.create!(:fact_name_id => fact.id, :value => fact_value)
        end

        def rescue_strategy_for_self
          Dynflow::Action::Rescue::Skip
        end
      end
    end
  end
end
