module Orchestrate
  module Helpers

    # Helpers for remote actions
    # wraps the plan/run/finalize methods to include the info about the user
    # that triggered the action.
    module RemoteAction

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods

        def generate_phase(phase_module)
          super.tap do |phase_class|
            case
            when phase_module == Dynflow::Action::PlanPhase
              phase_class.alias_method_chain :plan_self, :remote_user
            when phase_module == Dynflow::Action::RunPhase
              if phase_class.instance_methods.include?(:run)
                phase_class.alias_method_chain :run, :remote_user
              end
            when phase_module == Dynflow::Action::FinalizePhase
              if phase_class.instance_methods.include?(:finalize)
                phase_class.alias_method_chain :finalize, :remote_user
              end
            end
          end
        end

      end

      def plan_self_with_remote_user(input)
        remote_user = { remote_user: User.current.remote_id }
        plan_self_without_remote_user(input.merge(remote_user))
      end

      def run_with_remote_user
        as_remote_user { run_without_remote_user }
      end

      def finalize_with_remote_user
        as_remote_user { finalize_without_remote_user }
      end

      def pulp
        ::Katello.pulp_server.resources
      end

      private

      def with_cp_user(input)
        input.merge(cp_oauth_header: User.current.cp_oauth_header)
      end

      def as_cp_user(&block)
        User.set_cp_config('cp-user' => input[:remote_user], &block)
      end

      def as_pulp_user(&block)
        User.set_pulp_config(input[:remote_user], &block)
      end

      def as_foreman_user(&block)
        Thread.current[:foreman_user] = input[:remote_user]
        yield
      ensure
        Thread.current[:foreman_user] = nil
      end

      def as_remote_user
        as_cp_user do
          as_pulp_user do
            as_foreman_user do
              yield
            end
          end
        end
      end

    end
  end
end
