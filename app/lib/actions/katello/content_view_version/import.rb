module Actions
  module Katello
    module ContentViewVersion
      class Import < Actions::EntryAction
        PULP_USER = 'pulp'.freeze

        def plan(content_view, path:, metadata: nil)
          content_view.check_ready_to_import!
          unless SmartProxy.pulp_primary.pulp3_repository_type_support?(::Katello::Repository::YUM_TYPE)
            fail ::Katello::HttpErrors::BadRequest, _("This API endpoint is only valid for Pulp 3 repositories.")
          end
          ::Katello::Pulp3::ContentViewVersion::Import.check_permissions!(path, assert_metadata: metadata.nil?)
          metadata_json = if metadata
                            JSON.parse(metadata).with_indifferent_access
                          else
                            ::Katello::Pulp3::ContentViewVersion::Import.metadata(path)
                          end

          major = metadata_json[:content_view_version][:major]
          minor = metadata_json[:content_view_version][:minor]

          if ::Katello::ContentViewVersion.where(major: major, minor: minor, content_view: content_view).exists?
            cvv_name = "#{content_view.name} #{major}.#{minor}"
            fail _("Content View Version specified in the metadata - '%{name}' already exists. "\
                    "If you wish to replace the existing version, delete %{name} and try again. " % { name: cvv_name })
          end

          plan_action(::Actions::Katello::ContentView::Publish, content_view, '',
                        path: path,
                        import_only: true,
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
