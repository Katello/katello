module Actions
  module Katello
    module ContentViewVersion
      class ImportLibrary < Actions::EntryAction
        def plan(organization, path:, metadata:)
          action_subject(organization)
          plan_action(::Actions::Katello::ContentViewVersion::Import, organization: organization,
                                                                      path: path,
                                                                      metadata: metadata)
        end

        def humanized_name
          _("Import Default Content View")
        end
      end
    end
  end
end
