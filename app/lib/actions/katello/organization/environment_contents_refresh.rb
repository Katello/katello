module Actions
  module Katello
    module Organization
      class EnvironmentContentsRefresh < Actions::AbstractAsyncTask
        middleware.use Actions::Middleware::PropagateCandlepinErrors

        def plan(organization)
          organization.content_view_environments.each do |cve|
            plan_action(
              Actions::Candlepin::Environment::SetContent,
              cve.content_view,
              cve.owner,
              cve
            )
          end
        end
      end
    end
  end
end
