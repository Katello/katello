module Actions
  module Katello
    module Host
      class Update < Actions::EntryAction
        middleware.use ::Actions::Middleware::RemoteAction

        def queue
          ::Katello::HOST_TASKS_QUEUE
        end

        def plan(host, consumer_params = nil)
          input[:hostname] = host.name
          action_subject host
          sequence do
            host.content_facet.save! if host.content_facet

            auto_attach_enabled_via_checkin = consumer_params.try(:[], 'autoheal')

            if host.subscription_facet
              consumer_params ||= host.subscription_facet.consumer_attributes

              host_uuid = consumer_params.dig(:facts, 'dmi.system.uuid')
              if ::Katello::Host::SubscriptionFacet.override_dmi_uuid?(host_uuid)
                # if host reported a dmi uuid to treat as a duplicate, override it with the stored host param
                override_value = host.subscription_facet.dmi_uuid_override&.value
                override_value ||= host.subscription_facet.update_dmi_uuid_override&.value
                consumer_params[:facts]['dmi.system.uuid'] = override_value
              end

              cp_update = plan_action(::Actions::Candlepin::Consumer::Update, host.subscription_facet.uuid, consumer_params)
            end

            if auto_attach_enabled_via_checkin
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
          if Setting[:host_update_lock]
            :link
          else
            :update
          end
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
