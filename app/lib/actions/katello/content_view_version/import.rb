module Actions
  module Katello
    module ContentViewVersion
      class Import < Actions::EntryAction
        def plan(content_view, path:, metadata:)
          content_view.check_ready_to_import!
          unless SmartProxy.pulp_primary.pulp3_repository_type_support?(::Katello::Repository::YUM_TYPE)
            fail ::Katello::HttpErrors::BadRequest, _("This API endpoint is only valid for Pulp 3 repositories.")
          end

          ::Katello::Pulp3::ContentViewVersion::Import.check!(content_view: content_view, metadata: metadata, path: path)

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
