module Actions
  module Katello
    module ContentView
      class Promote < Actions::EntryAction
        middleware.use Actions::Middleware::KeepCurrentUser

        def plan(version, environments, is_force = false)
          action_subject(version.content_view)
          version.check_ready_to_promote!(environments)

          fail ::Katello::HttpErrors::BadRequest, _("Cannot promote environment out of sequence. Use force to bypass restriction.") if !is_force && !version.promotable?(environments)

          environments.each do |environment|
            plan_action(ContentView::PromoteToEnvironment, version, environment)
          end
        end
      end
    end
  end
end
