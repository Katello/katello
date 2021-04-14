module Actions
  module Katello
    module ContentViewVersion
      class Import < Actions::EntryAction
        def plan(organization:, path:, metadata:, library: false)
          fail _("Content view not provided in the metadata") if metadata[:content_view].blank?
          content_view = ::Katello::Pulp3::ContentViewVersion::Import.
                                find_or_create_import_view(organization: organization,
                                                           metadata: metadata[:content_view],
                                                           library: library)
          content_view.check_ready_to_import!
          ::Katello::Pulp3::ContentViewVersion::Import.check!(content_view: content_view,
                                                              metadata: metadata,
                                                              path: path,
                                                              smart_proxy: SmartProxy.pulp_primary!)

          major = metadata[:content_view_version][:major]
          minor = metadata[:content_view_version][:minor]

          sequence do
            plan_action(AutoCreateProducts, organization: content_view.organization, metadata: metadata)
            plan_action(AutoCreateRepositories, organization: content_view.organization, metadata: metadata)
            plan_action(ResetContentViewRepositoriesFromMetadata, content_view: content_view, metadata: metadata)
            plan_action(::Actions::Katello::ContentView::Publish, content_view, '',
                          path: path,
                          metadata: metadata,
                          importing: true,
                          major: major,
                          minor: minor)
          end
        end

        def humanized_name
          _("Import Content View Version")
        end
      end
    end
  end
end
