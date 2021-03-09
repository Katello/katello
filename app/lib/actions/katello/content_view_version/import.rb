module Actions
  module Katello
    module ContentViewVersion
      class Import < Actions::EntryAction
        def plan(content_view, path:, metadata:)
          content_view.check_ready_to_import!

          ::Katello::Pulp3::ContentViewVersion::Import.check!(content_view: content_view, metadata: metadata, path: path)
          ::Katello::Pulp3::ContentViewVersion::Import.reset_content_view_repositories_from_metadata!(content_view: content_view, metadata: metadata)

          major = metadata[:content_view_version][:major]
          minor = metadata[:content_view_version][:minor]

          plan_action(::Actions::Katello::ContentView::Publish, content_view, '',
                        path: path,
                        metadata: metadata,
                        importing: true,
                        major: major,
                        minor: minor)
        end

        def humanized_name
          _("Import Content View Version")
        end
      end
    end
  end
end
