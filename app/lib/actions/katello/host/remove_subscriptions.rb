module Actions
  module Katello
    module Host
      class RemoveSubscriptions < Actions::EntryAction
        middleware.use Actions::Middleware::KeepCurrentUser

        def plan(host, pools_with_quantities_params)
          action_subject(host)
          pool_ids = []
          sequence do
            pools_with_quantities = pools_with_quantities_params.map do |pool_with_quantity|
              ::Katello::PoolWithQuantities.fetch(pool_with_quantity)
            end
            cp_consumer = host.subscription_facet.candlepin_consumer
            entitlements = pools_with_quantities.map do |pool_with_quantities|
              cp_consumer.filter_entitlements(pool_with_quantities.pool.cp_id, pool_with_quantities.quantities)
            end

            entitlements.flatten.each do |entitlement|
              pool_ids << entitlement['pool']['id']
              plan_action(::Actions::Candlepin::Consumer::RemoveSubscription, :uuid => host.subscription_facet.uuid,
                          :entitlement_id => entitlement['id'], :pool_id => entitlement['pool']['id'])
            end
          end
          plan_self(:host_id => host.id, :host_name => host.name, :pool_ids => pool_ids)
        end

        def finalize
          ::Katello::Pool.where(:cp_id => input[:pool_ids]).map { |pool| pool.import_data(false) }
          host = ::Host.find_by(:id => input[:host_id])
          host.subscription_facet.update_subscription_status
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end

        def humanized_name
          if input.try(:[], :host_name)
            _('Remove subscriptions from %s') % (input[:host_name] || _('Unknown'))
          else
            _('Remove subscriptions')
          end
        end

        def resource_locks
          :link
        end
      end
    end
  end
end
