module Actions
  module Katello
    module Host
      class UpdateContentOverrides < Actions::EntryAction
        middleware.use Actions::Middleware::KeepCurrentUser

        def plan(host, content_overrides)
          action_subject(host)
          plan_action(::Actions::Candlepin::Consumer::UpdateContentOverrides,
                      :uuid => host.subscription_facet.uuid,
                      :content_overrides => content_overrides.map(&:to_entitlement_hash))
          plan_self(:host_id => host.id, :host_name => host.name)
        end

        def humanized_name
          if input.try(:[], :host_name)
            _('Update Content Overrides to %s') % (input[:host_name] || _('Unknown'))
          else
            _('Update Content Overrides')
          end
        end

        def resource_locks
          :link
        end
      end
    end
  end
end
