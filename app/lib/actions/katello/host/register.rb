module Actions
  module Katello
    module Host
      class Register < Actions::EntryAction
        middleware.use ::Actions::Middleware::RemoteAction

        def plan(host, system, consumer_params, content_view_environment, activation_keys = [])
          sequence do
            plan_action(Katello::Host::Unregister, host) unless host.new_record?

            unless activation_keys.empty?
              content_view_environment ||= lookup_content_view_environment(activation_keys)
              set_host_collections(system, activation_keys)
            end

            fail _('Content View and Environment not set for registration.') if content_view_environment.nil?

            system = plan_system(system, content_view_environment, consumer_params)
            system.disable_auto_reindex!
            system.save!

            host.content_aspect = plan_content_aspect(host, content_view_environment)
            host.subscription_aspect = plan_subscription_aspect(host, activation_keys, consumer_params)
            host.content_host = system
            host.save!

            action_subject host

            connect_to_smart_proxy(host)

            cp_create = plan_action(Candlepin::Consumer::Create, cp_environment_id: content_view_environment.cp_id,
                                    consumer_parameters: consumer_params, activation_keys: activation_keys.map(&:cp_name))
            return if cp_create.error

            plan_self(uuid: cp_create.output[:response][:uuid], host_id: host.id, hostname: host.name, :system_id => system.id)
            plan_action(Pulp::Consumer::Create, uuid: cp_create.output[:response][:uuid], name: host.name)
            plan_action(ElasticSearch::Reindex, system)
          end
        end

        def humanized_name
          _("Register Host %s") % input[:hostname]
        end

        def finalize
          host = ::Host.find(input[:host_id])
          host.content_aspect.update_attributes(:uuid => input[:uuid])
          host.subscription_aspect.update_attributes(:uuid => input[:uuid])

          system = ::Katello::System.find(input[:system_id])
          system.uuid = input[:uuid]
          system.save!
        end

        def connect_to_smart_proxy(system)
          smart_proxy = SmartProxy.where(:name => system.name).first

          if smart_proxy
            smart_proxy.content_host = system
            smart_proxy.organizations << system.organization unless smart_proxy.organizations.include?(system.organization)
            smart_proxy.save!
          end
        end

        private

        def set_host_collections(system, activation_keys)
          host_collection_ids = activation_keys.flat_map(&:host_collection_ids).compact.uniq

          host_collection_ids.each do |host_collection_id|
            host_collection = ::Katello::HostCollection.find(host_collection_id)
            if !host_collection.unlimited_hosts && host_collection.max_hosts >= 0 &&
               host_collection.systems.length >= host_collection.max_hosts
              fail _("Host collection '%{name}' exceeds maximum usage limit of '%{limit}'") %
                       {:limit => host_collection.max_content_hosts, :name => host_collection.name}
            end
          end
          system.foreman_host.host_collection_ids = host_collection_ids
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

        def plan_system(system, content_view_environment, consumer_params)
          system.facts = consumer_params[:facts]
          system.cp_type = consumer_params[:type]
          system.name = consumer_params[:name]
          system.serviceLevel = consumer_params[:serviceLevel]
          system.content_view = content_view_environment.content_view
          system.environment = content_view_environment.environment
          system
        end

        def plan_content_aspect(host, content_view_environment)
          content_aspect = host.content_aspect || ::Katello::Host::ContentAspect.new
          content_aspect.content_view = content_view_environment.content_view
          content_aspect.lifecycle_environment = content_view_environment.environment
          content_aspect
        end

        def plan_subscription_aspect(host, activation_keys, consumer_params)
          subscription_aspect = host.subscription_aspect || ::Katello::Host::SubscriptionAspect.new
          subscription_aspect.host = host
          subscription_aspect.update_from_consumer_attributes(consumer_params)
          subscription_aspect.activation_keys = activation_keys
          subscription_aspect
        end
      end
    end
  end
end
