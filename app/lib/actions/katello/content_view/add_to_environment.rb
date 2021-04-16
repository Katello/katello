module Actions
  module Katello
    module ContentView
      class AddToEnvironment < Actions::Base
        def plan(content_view_version, environment)
          cve = ::Katello::ContentViewManager.add_version_to_environment(
            content_view_version: content_view_version,
            environment: environment
          )

          ::Katello::ContentViewManager.create_candlepin_environment(
            content_view_environment: cve
          )

          content_view_version.save!
        end
      end
    end
  end
end
