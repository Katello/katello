module Actions
  module Katello
    module System
      class Create < Actions::EntryAction
        middleware.use ::Actions::Middleware::RemoteAction

        def plan(system, activation_keys = [])
          system.disable_auto_reindex!

          unless activation_keys.empty?
            activation_key_plan = plan_action(Katello::System::ActivationKeys, system, activation_keys)
            return if activation_key_plan.error
          end

          # we need to prepare the input for consumer create before we call save!
          # as the before filters do some magic with the attributes
          consumer_create_input = { cp_environment_id:   system.cp_environment_id,
                                    organization_label:  system.organization.label,
                                    name:                system.name,
                                    cp_type:             system.cp_type,
                                    facts:               system.facts,
                                    installed_products:  system.installedProducts,
                                    autoheal:            system.autoheal,
                                    release_ver:         system.release,
                                    service_level:       system.serviceLevel,
                                    last_checkin:        system.lastCheckin,
                                    uuid:                system.uuid,
                                    capabilities:        system.capabilities,
                                    guest_ids:           system.guestIds,
                                    activation_keys:     activation_keys.map(&:cp_name) }
          system.save!
          action_subject system

          connect_to_smart_proxy(system)

          cp_create = plan_action(Candlepin::Consumer::Create, consumer_create_input)
          return if cp_create.error

          plan_self(uuid: cp_create.output[:response][:uuid])
          plan_action(Pulp::Consumer::Create,
                      uuid: cp_create.output[:response][:uuid],
                      name: system.name)
          plan_action ElasticSearch::Reindex, system
        end

        def humanized_name
          _("Create")
        end

        def finalize
          system = ::Katello::System.find(input[:system][:id])
          system.disable_auto_reindex!
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
      end
    end
  end
end
