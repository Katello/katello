module Actions
  module Katello
    module User
      class Create < Actions::EntryAction
        def plan(user)
          action_subject user
          sequence do
            plan_action(Pulp::User::Create, remote_id: user.remote_id)
            plan_action(Pulp::Superuser::Add, remote_id: user.remote_id)
          end
        end
      end
    end
  end
end
