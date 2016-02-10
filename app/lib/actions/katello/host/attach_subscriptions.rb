module Actions
  module Katello
    module Host
      class AttachSubscriptions < Actions::EntryAction
        middleware.use Actions::Middleware::KeepCurrentUser

        def plan(host, pools_with_quantities)
          action_subject(host)

          sequence do
            pool_ids = []
            pools_with_quantities.each do |pool_with_quantities|
              pool_ids << pool_with_quantities.pool.id
              pool_with_quantities.quantities.each do |quantity|
                plan_action(::Actions::Candlepin::Consumer::AttachSubscription, :uuid => host.subscription_facet.uuid,
                            :pool_uuid => pool_with_quantities.pool.cp_id, :quantity => quantity)
              end
            end

            plan_self(:pool_ids => pool_ids, :host_name => host.name)
          end
        end

        def finalize
          ::Katello::Pool.where(:id => input[:pool_ids]).each(&:import_data)
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end

        def humanized_name
          if input.try(:[], :host_name)
            _('Attach subscriptions to %s') % (input[:host_name] || _('Unknown'))
          else
            _('Attach subscriptions')
          end
        end

        def resource_locks
          :link
        end
      end
    end
  end
end
