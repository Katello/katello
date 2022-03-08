module Actions
  module Katello
    module ContentViewVersion
      class Import < Actions::EntryAction
        attr_accessor :content_view
        def plan(organization:, path:, metadata:)
          fail _("Content view not provided in the metadata") if metadata[:content_view].blank?

          content_view = ::Katello::Pulp3::ContentViewVersion::Import.
                                find_or_create_import_view(organization: organization,
                                                           metadata: metadata[:content_view])
          content_view.check_ready_to_import!
          self.content_view = content_view
          ::Katello::Pulp3::ContentViewVersion::Import.check!(content_view: content_view,
                                                              metadata: metadata,
                                                              path: path,
                                                              smart_proxy: SmartProxy.pulp_primary!)

          major = metadata[:content_view_version][:major]
          minor = metadata[:content_view_version][:minor]
          description = metadata[:content_view_version][:description]

          gpg_helper = ::Katello::Pulp3::ContentViewVersion::ImportGpgKeys.
                          new(organization: organization,
                              metadata: metadata)
          gpg_helper.import!

          sequence do
            plan_action(AutoCreateProducts, organization: content_view.organization, metadata: metadata)
            plan_action(AutoCreateRepositories, organization: content_view.organization, metadata: metadata)
            plan_action(AutoCreateRedhatRepositories, organization: content_view.organization, metadata: metadata)
            plan_action(ResetContentViewRepositoriesFromMetadata, content_view: content_view, metadata: metadata)
            plan_action(::Actions::Katello::ContentView::Publish, content_view, description,
                          path: path,
                          metadata: metadata,
                          importing: true,
                          major: major,
                          minor: minor)
            plan_self(content_view_id: content_view.id)
          end
        end

        def finalize
          if task.execution_plan.run_steps.any? { |s| s.action_class == ::Actions::Pulp3::ContentViewVersion::Import && s.state != :success }
            ::Katello::EventQueue.push_event(::Katello::Events::DeleteLatestContentViewVersion::EVENT_TYPE, input[:content_view_id])
          end
        end

        def humanized_name
          _("Import Content View Version")
        end
      end
    end
  end
end
