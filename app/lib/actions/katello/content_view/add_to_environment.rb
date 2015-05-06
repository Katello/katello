module Actions
  module Katello
    module ContentView
      class AddToEnvironment < Actions::Base
        def plan(content_view_version, environment)
          content_view = content_view_version.content_view
          if cve = content_view.content_view_environment(environment)
            content_view_version.content_view_environments << cve
          else
            cve = content_view.add_environment(environment, content_view_version)
            plan_action(ContentView::EnvironmentCreate, cve)
          end
          content_view_version.save!
        end
      end
    end
  end
end
