module Actions
  module Katello
    module Host
      class UpdateContentOverrides < Actions::EntryAction
        middleware.use Actions::Middleware::KeepCurrentUser

        def plan(host, content_override_params, prune_invalid_content_overrides = true)
          action_subject(host)
          plan_self(:host_id => host.id, :host_name => host.name, :content_overrides => content_override_params,
                    :prune_invalid_content_overrides => prune_invalid_content_overrides)
        end

        def run
          content_overrides = input[:content_overrides].map do |override|
            ::Katello::ContentOverride.fetch(override)
          end
          prune_invalid_content_overrides = input[:prune_invalid_content_overrides]
          host = ::Host.find(input[:host_id])
          if prune_invalid_content_overrides
            content_overrides = content_overrides.select do |override|
              host.valid_content_override_label?(override.content_label)
            end
          end

          ::Katello::Resources::Candlepin::Consumer.update_content_overrides(host.subscription_facet.uuid,
                                                                            content_overrides.map(&:to_entitlement_hash))
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
