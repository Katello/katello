module Actions
  module Katello
    module CapsuleContent
      class ConfigureCapsule < ::Actions::EntryAction
        def plan(capsule)
          sequence do
            plan_action(Pulp::Consumer::ActivateNode, capsule.consumer)
            plan_action(ManageBoundRepositories, capsule)
          end
        end
      end
    end
  end
end
