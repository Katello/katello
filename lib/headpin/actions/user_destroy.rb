module Headpin
  module Actions
    class UserDestroy < Dynflow::Action

      def plan(user)
        plan_self('id' => user.id, 'username' => user.username)
      end

      input_format do
        param :id, String
        param :username, String
      end

    end
  end
end
