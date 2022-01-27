module Actions
  module Katello
    module ContentViewVersion
      class ImportRepository < Actions::EntryAction
        def plan(organization, path:, metadata:)
          action_subject(organization)
          sequence do
            plan_action(::Actions::Katello::ContentViewVersion::Import,
                                            organization: organization,
                                            path: path,
                                            metadata: metadata)
          end
        end

        def humanized_name
          _("Import Repository")
        end
      end
    end
  end
end
