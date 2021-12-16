module Actions
  module Katello
    module ContentView
      class RemoveVersion < Actions::EntryAction
        def plan(version)
          middleware.use Actions::Middleware::SwitchoverCheck

          action_subject(version.content_view)
          version.validate_destroyable!

          history = ::Katello::ContentViewHistory.create!(:content_view_version => version,
                                                          :user => ::User.current.login,
                                                          :status => ::Katello::ContentViewHistory::IN_PROGRESS,
                                                          :action => ::Katello::ContentViewHistory.actions[:removal],
                                                          :task => self.task)

          plan_action(ContentViewVersion::Destroy, version)
          plan_self(history_id: history.id)
        end

        def finalize
          history = ::Katello::ContentViewHistory.find(input[:history_id])
          history.status = ::Katello::ContentViewHistory::SUCCESSFUL
          history.save!
        end

        def humanized_name
          _("Remove Version")
        end
      end
    end
  end
end
