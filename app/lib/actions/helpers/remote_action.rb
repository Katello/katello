module Actions
  module Helpers

    # Helpers for remote actions
    # wraps the plan/run/finalize methods to include the info about the user
    # that triggered the action.
    module RemoteAction
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def create_plan_phase
          super.tap { |klass| klass.alias_method_chain :plan_self, :remote_user }
        end

        def create_run_phase
          super.tap do |klass|
            if klass.instance_methods.include?(:run)
              klass.alias_method_chain :run, :remote_user
            end
          end
        end

        def create_finalize_phase
          super.tap do |klass|
            if klass.instance_methods.include?(:finalize)
              klass.alias_method_chain :finalize, :remote_user
            end
          end
        end
      end

      def plan_self_with_remote_user(input)
        remote_user = { remote_user: User.current.remote_id }
        plan_self_without_remote_user(input.merge(remote_user))
      end

      def run_with_remote_user(event = nil)
        as_remote_user { run_without_remote_user(*Array(event)) }
      end

      def finalize_with_remote_user
        as_remote_user { finalize_without_remote_user }
      end

      def pulp_resources
        ::Katello.pulp_server.resources
      end

      def pulp_extensions
        ::Katello.pulp_server.extensions
      end

      private

      #def with_cp_user(input)
      #  input.merge(cp_oauth_header: User.current.cp_oauth_header)
      #end

      def as_cp_user(&block)
        fail 'missing :remote_user' unless input[:remote_user]
        User.set_cp_config('cp-user' => input[:remote_user], &block)
      end

      def as_pulp_user(&block)
        fail 'missing :remote_user' unless input[:remote_user]
        User.set_pulp_config(input[:remote_user], &block)
      end

      def as_foreman_user
        fail 'missing :remote_user' unless input[:remote_user]
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
