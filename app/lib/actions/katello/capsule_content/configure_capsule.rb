module Actions
  module Katello
    module CapsuleContent
      class ConfigureCapsule < ::Actions::EntryAction
        def plan(capsule, environment, content_view)
          sequence do
            plan_action(RemoveUnneededRepos, capsule)
            plan_action(CreateOrUpdate, capsule, environment, content_view)
          end
        end
      end
    end
  end
end
