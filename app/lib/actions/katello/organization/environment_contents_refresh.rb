module Actions
  module Katello
    module Organization
      class EnvironmentContentsRefresh < Actions::AbstractAsyncTask
        middleware.use Actions::Middleware::PropagateCandlepinErrors

        def plan(organization)
          organization.content_view_environments.each do |cvenv|
            plan_action(
              Actions::Candlepin::Environment::SetContent,
              cvenv.content_view,
              cvenv.owner,
              cvenv
            )
          end
        end
      end
    end
  end
end
