module Actions
  module Katello
    module Host
      class Update < Actions::EntryAction
        middleware.use ::Actions::Middleware::RemoteAction

        def plan(host, consumer_params = nil)
          action_subject host
          plan_self(:hostname => host.name, :facts => consumer_params.try(:[], :facts), :host_id => host.id)

          sequence do
            host.content_facet.save! if host.content_facet

            if host.subscription_facet
              unless consumer_params
                consumer_params = host.subscription_facet.consumer_attributes
              end

              host.subscription_facet.update_from_consumer_attributes(consumer_params)
              host.subscription_facet.save!
              plan_action(::Actions::Candlepin::Consumer::Update, host.subscription_facet.uuid, consumer_params)
            end

            if host.subscription_facet.try(:autoheal)
              plan_action(::Actions::Candlepin::Consumer::AutoAttachSubscriptions, :uuid => host.subscription_facet.uuid)
            end
          end
        end

        def run
          User.as_anonymous_admin do
            host = ::Host.find(input[:host_id])
            unless input[:facts].blank?
              ::Katello::Host::SubscriptionFacet.update_facts(host, input[:facts])
              input[:facts] = 'TRIMMED'
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
          if input.try(:[], :hostname)
            _('Update for host %s') % input[:hostname]
          else
            _('Update for host')
          end
        end
      end
    end
  end
end
