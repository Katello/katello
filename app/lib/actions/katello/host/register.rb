module Actions
  module Katello
    module Host
      class Register < Actions::EntryAction
        middleware.use ::Actions::Middleware::RemoteAction

        def plan(host, consumer_params, content_view_environment, activation_keys = [])
          sequence do
            unless host.new_record?
              host.save!
              plan_action(Katello::Host::Unregister, host)
              host.reload
            end

            unless activation_keys.empty?
              content_view_environment ||= lookup_content_view_environment(activation_keys)
              set_host_collections(host, activation_keys)
            end
            fail _('Content View and Environment not set for registration.') if content_view_environment.nil?

            host.save!
            host.content_facet = plan_content_facet(host, content_view_environment)
            host.subscription_facet = plan_subscription_facet(host, activation_keys, consumer_params)
            host.save!

            action_subject host

            cp_create = plan_action(Candlepin::Consumer::Create, cp_environment_id: content_view_environment.cp_id,
                                    consumer_parameters: consumer_params, activation_keys: activation_keys.map(&:cp_name))
            return if cp_create.error

            plan_self(uuid: cp_create.output[:response][:uuid], host_id: host.id, hostname: host.name,
                      user_id: User.current.id, :facts => consumer_params[:facts])
            plan_action(Pulp::Consumer::Create, uuid: cp_create.output[:response][:uuid], name: host.name)

            begin
              set_content_and_subscription_uuids(host, cp_create.input[:response][:uuid])
            rescue => e
              ::Katello::Resources::Candlepin::Consumer.destroy(cp_create.input[:response][:uuid])
              raise e
            end
          end
        end

        def humanized_name
          if input.try(:[], :hostname)
            _('Register Host %s') % (input[:hostname] || _('Unknown'))
          else
            _('Register Host')
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

        def finalize
          User.as_anonymous_admin do
            host = ::Host.find(input[:host_id])
            host.subscription_facet.update_from_consumer_attributes(host.subscription_facet.candlepin_consumer.
                consumer_attributes.except(:installedProducts, :guestIds, :facts))
            host.subscription_facet.save!
            host.subscription_facet.update_subscription_status
            host.content_facet.update_errata_status
            host.refresh_global_status!
          end
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end

        private

        def set_host_collections(host, activation_keys)
          host_collection_ids = activation_keys.flat_map(&:host_collection_ids).compact.uniq

          host_collection_ids.each do |host_collection_id|
            host_collection = ::Katello::HostCollection.find(host_collection_id)
            if !host_collection.unlimited_hosts && host_collection.max_hosts >= 0 &&
              host_collection.hosts.length >= host_collection.max_hosts
              fail _("Host collection '%{name}' exceeds maximum usage limit of '%{limit}'") %
                       {:limit => host_collection.max_hosts, :name => host_collection.name}
            end
          end
          host.host_collection_ids = host_collection_ids
        end

        def lookup_content_view_environment(activation_keys)
          activation_key = activation_keys.reverse.detect do |act_key|
            act_key.environment && act_key.content_view
          end
          if activation_key
            ::Katello::ContentViewEnvironment.where(:content_view_id => activation_key.content_view, :environment_id => activation_key.environment).first
          else
            fail _('At least one activation key must have a lifecycle environment and content view assigned to it')
          end
        end

        def plan_content_facet(host, content_view_environment)
          content_facet = host.content_facet || ::Katello::Host::ContentFacet.new(:host => host)
          content_facet.content_view = content_view_environment.content_view
          content_facet.lifecycle_environment = content_view_environment.environment
          content_facet.save!
          content_facet
        end

        def plan_subscription_facet(host, activation_keys, consumer_params)
          subscription_facet = host.subscription_facet || ::Katello::Host::SubscriptionFacet.new(:host => host)
          subscription_facet.last_checkin = DateTime.now
          subscription_facet.update_from_consumer_attributes(consumer_params.except(:installedProducts, :guestIds, :facts))
          subscription_facet.save!
          subscription_facet.activation_keys = activation_keys
          subscription_facet
        end

        def set_content_and_subscription_uuids(host, uuid)
          host.content_facet.uuid = uuid
          host.subscription_facet.uuid = uuid
          host.subscription_facet.user = User.current unless User.current.nil? || User.current.hidden?
          host.content_facet.save!
          host.subscription_facet.save!
        end
      end
    end
  end
end
