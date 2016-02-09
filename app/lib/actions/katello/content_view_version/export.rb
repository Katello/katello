module Actions
  module Katello
    module ContentViewVersion
      class Export < Actions::EntryAction
        middleware.use Actions::Middleware::KeepCurrentUser

        def plan(content_view_version, export_to_iso, since, iso_size)
          # assemble data to feed to Pulp
          start_date = since ? since.iso8601 : nil
          content_view = ::Katello::ContentView.find(content_view_version.content_view_id)
          org_label = ::Organization.find_by(:id => content_view.organization_id).label
          group_id = "#{org_label}-#{content_view.label}-"\
                     "v#{content_view_version.major}.#{content_view_version.minor}"

          repo_pulp_ids = content_view_version.archived_repos.
                            select { |r| r.content_type == 'yum' }.collect { |r| r.pulp_id }

          history = ::Katello::ContentViewHistory.create!(:content_view_version => content_view_version,
                                                          :user => ::User.current.login,
                                                          :status => ::Katello::ContentViewHistory::IN_PROGRESS,
                                                          :task => self.task)

          plan_action(Katello::Repository::Export, repo_pulp_ids, export_to_iso, start_date, iso_size,
                                                   group_id)
          plan_self(:history_id => history.id)
        end

        def humanized_name
          _("Export")
        end

        def finalize
          history = ::Katello::ContentViewHistory.find(input[:history_id])
          history.status = ::Katello::ContentViewHistory::SUCCESSFUL
          history.save!
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end
      end
    end
  end
end
