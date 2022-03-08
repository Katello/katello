module Actions
  module Katello
    module ContentView
      class Destroy < Actions::EntryAction
        middleware.use ::Actions::Middleware::RemoteAction

        def plan(content_view, options = {})
          action_subject(content_view)
          if options.fetch(:check_ready_to_destroy, true)
            content_view.check_ready_to_destroy!
          end

          sequence do
            concurrence do
              content_view.content_view_versions.each do |version|
                plan_action(ContentViewVersion::Destroy, version, options)
              end
            end

            if SmartProxy.pulp_primary&.pulp3_enabled?
              plan_action(Actions::Pulp3::ContentView::DeleteRepositoryReferences, content_view, SmartProxy.pulp_primary)
            end
            plan_self
          end
        end

        def finalize
          content_view = ::Katello::ContentView.where(id: input[:content_view][:id]).first
          return if content_view.blank?
          content_view.content_view_repositories.each(&:destroy)
          content_view.destroy!
        end

        def humanized_name
          _("Delete")
        end
      end
    end
  end
end
