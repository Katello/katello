module Actions
  module Katello
    module ContentViewVersion
      class ImportLibrary < Actions::EntryAction
        def plan(organization, path:, metadata:)
          action_subject(organization)
          unless SmartProxy.pulp_primary.pulp3_repository_type_support?(::Katello::Repository::YUM_TYPE)
            fail _("This action will become available after the Pulp 3 content migration")
          end
          ::Katello::Pulp3::ContentViewVersion::Import.check!(content_view: organization.default_content_view, metadata: metadata, path: path)

          version = organization.default_content_view_version
          history = ::Katello::ContentViewHistory.create!(:content_view_version => version,
            :user => ::User.current.login,
            :status => ::Katello::ContentViewHistory::IN_PROGRESS,
            :action => ::Katello::ContentViewHistory.actions[:importing],
            :task => self.task)

          sequence do
            plan_action(::Actions::Pulp3::Orchestration::ContentViewVersion::Import, version, path: path, metadata: metadata)
            concurrence do
              version.importable_repositories.each do |repo|
                sequence do
                  plan_action(Actions::Pulp3::Repository::SaveVersion, repo)
                  plan_action(Katello::Repository::MetadataGenerate, repo, :force => true)
                  plan_action(Katello::Repository::IndexContent, id: repo.id)
                end
              end
            end
            plan_self(history_id: history.id, organization_id: organization.id)
          end
        end

        def humanized_name
          _("Import Default Content View")
        end

        def rescue_strategy_for_self
          Dynflow::Action::Rescue::Skip
        end

        def finalize
          org = ::Organization.find(input[:organization_id])
          environment = org.library
          view = org.default_content_view
          version = org.default_content_view_version
          version.update_content_counts!
          # update errata applicability counts for all hosts in the CV & Library
          ::Katello::Host::ContentFacet.where(:content_view_id => view.id,
                                              :lifecycle_environment_id => environment.id).each do |facet|
            facet.update_applicability_counts
            facet.update_errata_status
          end
          ::Katello::ContentViewHistory.where(id: input[:history_id]).
            update_all(status: ::Katello::ContentViewHistory::SUCCESSFUL)

          if SmartProxy.sync_needed?(environment)
            ForemanTasks.async_task(ContentView::CapsuleSync,
                                    view,
                                    environment)
          end
        rescue ::Katello::Errors::CapsuleCannotBeReached => e # skip any capsules that cannot be connected to
          Rails.logger.warn e.to_s
        end
      end
    end
  end
end
