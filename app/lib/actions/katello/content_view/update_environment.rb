module Actions
  module Katello
    module ContentView
      class UpdateEnvironment < Actions::Base
        def plan(content_view, environment, new_content_id = nil)
          view_env = content_view.content_view_environment(environment)
          content_ids = content_view.repos(environment).map(&:content_id).uniq.compact
          # in case we create new custom repository that doesn't have the
          # content_id set yet in the plan phase, we allow to pass it as
          # additional argument
          content_ids << new_content_id if new_content_id && !content_ids.include?(new_content_id)
          plan_action(Candlepin::Environment::SetContent,
                      cp_environment_id: view_env.cp_id,
                      content_ids:       content_ids)

          plan_self(:environment_id => environment.id)
        end
      end
    end
  end
end
