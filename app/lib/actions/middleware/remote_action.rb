module Actions
  module Middleware
    # Helpers for remote actions
    # wraps the plan/run/finalize methods to include the info about the user
    # that triggered the action.
    class RemoteAction < Dynflow::Middleware
      def plan(*args, **kwargs)
        fail "No current user is set. Please set User.current to perform a remote action" if User.current.nil?
        pass(*args, **kwargs).tap do
          action.input[:remote_user] = User.remote_user
          action.input[:remote_cp_user] = User.remote_user
        end
      end

      def run(*args)
        as_remote_user { pass(*args) }
      end

      def finalize
        as_remote_user { pass }
      end

      private

      def as_cp_user(&block)
        fail 'missing :remote_user' unless cp_user
        ::User.cp_config('cp-user' => cp_user, &block)
      end

      def remote_user
        action.input[:remote_user]
      end

      def cp_user
        action.input[:remote_cp_user]
      end

      def as_remote_user
        as_cp_user do
          yield
        end
      end
    end
  end
end
