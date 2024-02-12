module Actions
  module Katello
    module ContentViewVersion
      class ImportRepository < Actions::EntryAction
        def plan(organization, opts = {})
          action_subject(organization)
          sequence do
            plan_action(::Actions::Katello::ContentViewVersion::Import,
                                            organization: organization,
                                            path: opts[:path],
                                            metadata: opts[:metadata])
          end
        end

        def humanized_name
          _("Import Repository")
        end
      end
    end
  end
end
