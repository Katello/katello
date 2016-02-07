module Actions
  module Katello
    module Host
      class Update < Actions::EntryAction
        middleware.use ::Actions::Middleware::RemoteAction

        def plan(host, consumer_params = nil)
          action_subject host
          host.content_facet.save! if host.content_facet
          host.subscription_facet.save!

          consumer_params = nil
          if consumer_params
            host.subscription_facet.update_from_consumer_attributes(consumer_params)
            host.subscription_facet.save!
          else
            consumer_params = host.subscription_facet.consumer_attributes
            if host.content_facet
              host.content_host.content_view = host.content_facet.try(:content_view)
              host.content_host.environment = host.content_facet.try(:lifecycle_environment)
              host.content_host.save!
            end
          end

          sequence do
            plan_action(::Actions::Candlepin::Consumer::Update, host.subscription_facet.uuid, consumer_params)
            plan_action(::Actions::Candlepin::Consumer::AutoAttachSubscriptions, :uuid => host.subscription_facet.uuid) if host.subscription_facet.autoheal
          end

          plan_self(:hostname => host.name)
        end

        def resource_locks
          :update
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end

        def humanized_name
          if input.try([], :hostname)
            _('Update for host %s') % (input[:hostname])
          else
            _('Update for host')
          end
        end
      end
    end
  end
end
