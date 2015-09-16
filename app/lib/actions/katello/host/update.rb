module Actions
  module Katello
    module Host
      class Update < Actions::EntryAction
        middleware.use ::Actions::Middleware::RemoteAction

        def plan(host, consumer_params = nil)
          action_subject host
          host.content_aspect.save!
          host.subscription_aspect.save!

          if consumer_params
            host.subscription_aspect.update_from_consumer_attributes(consumer_params)
            host.subscription_aspect.save!
          else
            consumer_params = host.subscription_aspect.consumer_attributes
            host.content_host.content_view = host.content_aspect.try(:content_view)
            host.content_host.environment = host.content_aspect.try(:lifecycle_environment)
            host.content_host.save!
          end

          sequence do
            plan_action(::Actions::Candlepin::Consumer::Update, host.subscription_aspect.uuid, consumer_params)
            plan_action(::Actions::Candlepin::Consumer::AutoAttachSubscriptions, host.subscription_aspect) if host.subscription_aspect.autoheal
          end

          plan_self(:hostname => host.name)
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end

        def humanized_name
          _("Update for host %s") % input[:hostname]
        end
      end
    end
  end
end
