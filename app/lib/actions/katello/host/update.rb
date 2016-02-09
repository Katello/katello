module Actions
  module Katello
    module Host
      class Update < Actions::EntryAction
        middleware.use ::Actions::Middleware::RemoteAction

        def plan(host, consumer_params = nil)
          action_subject host
          plan_self(:hostname => host.name)

          sequence do
            host.content_facet.save! if host.content_facet
            host.subscription_facet.save! if host.subscription_facet

            if consumer_params && host.subscription_facet
              host.subscription_facet.update_from_consumer_attributes(consumer_params)
              host.subscription_facet.save!
              plan_action(::Actions::Candlepin::Consumer::Update, host.subscription_facet.uuid, consumer_params)
            elsif host.subscription_facet
              consumer_params = host.subscription_facet.consumer_attributes
            end

            if host.content_facet && host.content_host
              host.content_host.content_view = host.content_facet.try(:content_view)
              host.content_host.environment = host.content_facet.try(:lifecycle_environment)
              host.content_host.save!
            end
            if host.subscription_facet.try(:autoheal)
              plan_action(::Actions::Candlepin::Consumer::AutoAttachSubscriptions, :uuid => host.subscription_facet.uuid)
            end
          end
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
