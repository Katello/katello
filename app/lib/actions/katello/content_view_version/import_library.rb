module Actions
  module Katello
    module ContentViewVersion
      class ImportLibrary < Actions::EntryAction
        def plan(organization, opts = {})
          action_subject(organization)
          plan_action(::Actions::Katello::ContentViewVersion::Import, { organization: organization,
                                                                        path: opts[:path],
                                                                        metadata: opts[:metadata] })
        end

        def humanized_name
          _("Import Default Content View")
        end
      end
    end
  end
end
