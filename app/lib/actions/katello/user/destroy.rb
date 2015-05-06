module Actions
  module Katello
    module User
      class Destroy < Actions::EntryAction
        def plan(user)
          action_subject user

          sequence do
            plan_action(Pulp::Superuser::Remove, remote_id: user.remote_id)
            plan_action(Pulp::User::Destroy, remote_id: user.remote_id)
          end
        end
      end
    end
  end
end
