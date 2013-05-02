module Headpin
  module Actions
    class UserCreate < Dynflow::Action

      def plan(user)
        plan_self('username' => user.username,
                  'email' => user.email,
                  'hidden' => user.hidden?)
      end

      input_format do
        param :username, String
        param :email, String
        param :hidden, :bool
      end

    end
  end
end
