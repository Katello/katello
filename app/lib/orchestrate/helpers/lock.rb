module Orchestrate
  module Helpers

    # Helpers for locking the resource with the task
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

        # @see Lock.exclusive!
        def exclusive_lock(resource)
          ::Lock.exclusive!(resource, execution_plan_id)
        end

        # @see Lock.lock!
        def lock(resource, *lock_names)
          ::Lock.lock!(resource, execution_plan_id, *lock_names)
        end

        # @see Lock.link!
        def link(resource)
          ::Lock.link!(resource, execution_plan_id)
        end

      end

    end
  end
end
