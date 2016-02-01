module Actions
  module Katello
    module Host
      class RemoveSubscriptions < Actions::EntryAction
        middleware.use Actions::Middleware::KeepCurrentUser

        def plan(host, entitlements)
          action_subject(host)

          entitlements.each do |entitlement|
            plan_action(::Actions::Candlepin::Consumer::RemoveSubscription, :uuid => host.subscription_facet.uuid,
                        :entitlement_id => entitlement['id'])
            plan_self(:host_name => host.name)
          end
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end

        def humanized_name
          _('Attach subscriptions to %s') % (input[:host_name] || _('Unknown'))
        end

        def resource_locks
          :link
        end
      end
    end
  end
end
