module Actions
  module Middleware

    # Helpers for remote actions
    # wraps the plan/run/finalize methods to include the info about the user
    # that triggered the action.
    class RemoteAction < Dynflow::Middleware
      def plan(*args)
        pass(*args).tap { action.input[:remote_user] = User.current.remote_id }
      end

      def run(*args)
        as_remote_user { pass(*args) }
      end

      def finalize
        as_remote_user { pass }
      end

      private

      def as_cp_user(&block)
        fail 'missing :remote_user' unless remote_user
        User.set_cp_config('cp-user' => remote_user, &block)
      end

      def as_pulp_user(&block)
        fail 'missing :remote_user' unless remote_user
        User.set_pulp_config(remote_user, &block)
      end

      def remote_user
        action.input[:remote_user]
      end

      def as_remote_user
        as_cp_user do
          as_pulp_user do
            yield
          end
        end
      end

    end
  end
end
