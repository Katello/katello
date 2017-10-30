module Actions
  module Katello
    module Host
      class Update < Actions::EntryAction
        middleware.use ::Actions::Middleware::RemoteAction

        def plan(host, consumer_params = nil)
          action_subject host
          sequence do
            host.content_facet.save! if host.content_facet

            if host.subscription_facet
              unless consumer_params
                consumer_params = host.subscription_facet.consumer_attributes
              end
              cp_update = plan_action(::Actions::Candlepin::Consumer::Update, host.subscription_facet.uuid, consumer_params)
            end

            if consumer_params.present? && consumer_params['autoheal']
              plan_action(::Actions::Candlepin::Consumer::AutoAttachSubscriptions, :uuid => host.subscription_facet.uuid)
            end

            plan_self(:hostname => host.name, :consumer_params => consumer_params, :host_id => host.id,
                      :dependency => cp_update.try(:output))
          end
        end

        def run
          User.as_anonymous_admin do
            host = ::Host.find(input[:host_id])
            if input[:consumer_params].try(:[], :facts)
              ::Katello::Host::SubscriptionFacet.update_facts(host, input[:consumer_params][:facts])
            end
          end
        end

        def finalize
          User.as_anonymous_admin do
            unless input[:consumer_params].blank?
              host = ::Host.find(input[:host_id])
              host.subscription_facet.update_from_consumer_attributes(input[:consumer_params])
              host.subscription_facet.save!
              input[:consumer_params][:facts] = 'TRIMMED' if input[:consumer_params].try(:[], :facts)
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
