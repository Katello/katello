module Actions
  module Katello
    module ContentViewVersion
      class ImportLibrary < Actions::EntryAction
        def plan(organization, path:, metadata:)
          action_subject(organization)
          library_view = ::Katello::Pulp3::ContentViewVersion::Import.find_or_create_library_import_view(organization)
          plan_action(::Actions::Katello::ContentViewVersion::Import, content_view: library_view, path: path, metadata: metadata)
        end

        def humanized_name
          _("Import Default Content View")
        end
      end
    end
  end
end
