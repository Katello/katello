module Actions
  module Katello
    module ContentView
      class RemoveFromEnvironment < Actions::EntryAction
        include Helpers::ContentViewAutoPublisher

        def plan(content_view, environment)
          action_subject(content_view)
          content_view.check_remove_from_environment!(environment)

          cv_env = ::Katello::ContentViewEnvironment.where(:content_view_id => content_view.id,
                                                           :environment_id => environment.id).first

          if cv_env.nil?
            fail _("Cannot remove content view from environment. Content view '%{view}' is not in lifecycle environment '%{env}'.") %
              {view: content_view.name, env: environment.name}
          end

          history = ::Katello::ContentViewHistory.create!(:content_view_version => cv_env.content_view_version,
                                                          :environment => environment,
                                                          :user => ::User.current.login,
                                                          :status => ::Katello::ContentViewHistory::IN_PROGRESS,
                                                          :action => ::Katello::ContentViewHistory.actions[:removal],
                                                          :task => self.task)

          plan_action(ContentViewEnvironment::Destroy, cv_env)
          plan_self(history_id: history.id)
        end

        def finalize
          history = ::Katello::ContentViewHistory.find(input[:history_id])
          history.status = ::Katello::ContentViewHistory::SUCCESSFUL
          history.save!
        end

        def humanized_name
          _("Remove from Environment")
        end
      end
    end
  end
end
