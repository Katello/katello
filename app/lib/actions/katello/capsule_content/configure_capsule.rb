module Actions
  module Katello
    module CapsuleContent
      class ConfigureCapsule < ::Actions::EntryAction
        def plan(smart_proxy, environment, content_view, repository)
          sequence do
            plan_action(RemoveUnneededRepos, smart_proxy)
            plan_action(CreateRepos, smart_proxy, environment, content_view, repository)
          end
        end
      end
    end
  end
end
