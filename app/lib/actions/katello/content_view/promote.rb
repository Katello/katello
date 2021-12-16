module Actions
  module Katello
    module ContentView
      class Promote < Actions::EntryAction
        middleware.use Actions::Middleware::SwitchoverCheck

        def plan(version, environments, is_force = false, description = nil, incremental_update = false)
          action_subject(version.content_view)
          version.check_ready_to_promote!(environments)

          fail ::Katello::HttpErrors::BadRequest, _("Cannot promote environment out of sequence. Use force to bypass restriction.") if !is_force && !version.promotable?(environments)

          # Pass the environments as input in order to make them accessible to UI alerts
          plan_self(environments: environments.map(&:name))
          environments.each do |environment|
            sequence do
              plan_action(Katello::ContentViewVersion::BeforePromoteHook, :id => version.id)
              plan_action(ContentView::PromoteToEnvironment, version, environment, description, incremental_update)
              plan_action(Katello::ContentViewVersion::AfterPromoteHook, :id => version.id)
            end
          end
        end
      end
    end
  end
end
