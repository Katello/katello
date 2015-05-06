module Actions
  module Katello
    module Organization
      class AutoAttachSubscriptions < Actions::EntryAction
        def plan(organization)
          action_subject(organization)
          plan_action(Candlepin::Owner::AutoAttach, label: organization.label)
        end

        def humanized_name
          _("Auto-attach subscriptions")
        end
      end
    end
  end
end
