module Actions
  module Katello
    module ContentView
      class Promote < Actions::EntryAction
        middleware.use Actions::Middleware::KeepCurrentUser

        def plan(version, environments, is_force = false, description = nil, options = {})
          action_subject(version.content_view)
          version.check_ready_to_promote!(environments)

          fail ::Katello::HttpErrors::BadRequest, _("Cannot promote environment out of sequence. Use force to bypass restriction.") if !is_force && !version.promotable?(environments)

          environments.each do |environment|
            plan_action(ContentView::PromoteToEnvironment, version, environment, description,
                        :force_yum_metadata_regeneration => options[:force_yum_metadata_regeneration])
          end
        end
      end
    end
  end
end
