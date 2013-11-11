module Orchestrate
  module Helpers

    # Helpers for remote actions
    # wraps the plan/run/finalize methods to include the info about the user
    # that triggered the action.
    module Lock

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods

        def generate_phase(phase_module)
          super.tap do |phase_class|
            if phase_module == Dynflow::Action::PlanPhase
              phase_class.send(:include, PlanMethods)
            end
          end
        end

      end

      module PlanMethods

        def lock(model)
          DynflowLock.lock!(execution_plan_id, model)
        end

      end

    end
  end
end
