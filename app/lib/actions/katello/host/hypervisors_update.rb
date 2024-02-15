module Actions
  module Katello
    module Host
      class HypervisorsUpdate < Actions::EntryAction
        middleware.use ::Actions::Middleware::RemoteAction

        input_format do
          param :hypervisors
        end

        def run
          output[:results] = input[:results]
          @hypervisors = input[:hypervisors]
          return unless @hypervisors

          @duplicate_uuid_hypervisors = {}

          User.as_anonymous_admin do
            ActiveRecord::Base.transaction do
              load_resources
            end

            load_hosts_guests

            ActiveRecord::Base.transaction do
              @hosts.each do |uuid, host|
                update_host(uuid, host)
              end
            end

            @hosts.each do |uuid, host|
              update_facts(uuid, host)
            end
          end

          @duplicate_uuid_hypervisors.each do |hypervisor, existing_host|
            fail _("Host creation was skipped for %s because it shares a BIOS UUID with %s. " \
                   "To report this hypervisor, override its dmi.system.uuid fact or set 'candlepin.use_system_uuid_for_matching' " \
                   "to 'true' in the Candlepin configuration." % [hypervisor[:name], existing_host.name])
          end
        end

        private

        def load_hosts_guests
          @hosts.each do |uuid, host|
            host.subscription_facet ||= host.build_subscription_facet(uuid: uuid)
            # Only preload the virtual guests if 'guestIds' is not returned by Candlepin
            consumer = @candlepin_attributes[uuid]
            next unless consumer&.try(:[], 'guestIds')&.empty?
            host.subscription_facet.candlepin_consumer.virtual_guests
          end
        end

        # Loads all resources needed for refreshing subscription facet
        def load_resources
          @organizations = ::Organization.where(label: hypervisors_field(:organization_label)).index_by { |org| org.label }

          candlepin_data = ::Katello::Resources::Candlepin::Consumer.get_all_with_facts(hypervisors_field(:uuid))
          @candlepin_attributes = candlepin_data.index_by { |consumer| consumer[:uuid] }

          @hosts = {}
          @hosts.merge!(load_hosts_by_uuid)
          @hosts.merge!(load_hosts_by_duplicate_name)
          @hosts.merge!(create_missing_hosts)
        end

        def load_hosts_by_uuid
          hosts_by_uuid = ::Host.eager_load(:subscription_facet).where(katello_subscription_facets: { uuid: hypervisors_field(:uuid) })
          hosts_by_uuid.each do |host|
            validate_host_organization(host, host.organization.try(:id))
          end
          hosts_by_uuid.index_by { |host| host.subscription_facet.uuid }
        end

        def load_hosts_by_duplicate_name
          duplicate_names, duplicate_name_orgs = generate_duplicates_list

          hosts_by_dup_name = ::Host.preload(:subscription_facet).where(name: duplicate_names.keys)

          hosts_by_dup_name.each do |host|
            validate_host_organization(host, duplicate_name_orgs[host.name].try(:id))
          end

          hosts_by_dup_name.index_by { |host| duplicate_names[host.name] }
        end

        def create_missing_hosts
          # remaining hypervisors
          new_hypervisors = {}
          @hypervisors.each do |hypervisor|
            next if @hosts.key?(hypervisor[:uuid])

            created_host = new_hypervisors[hypervisor[:uuid]]
            if created_host
              # we've already created a host record for this duplicate hypervisor
              # track it so we can message later, and continue processing the remaining hypervisors
              @duplicate_uuid_hypervisors[hypervisor] = created_host
              next
            end

            duplicate_name, org = duplicate_name(hypervisor, @candlepin_attributes[hypervisor[:uuid]])
            new_hypervisors[hypervisor[:uuid]] = create_host_for_hypervisor(duplicate_name, org)
          end
          new_hypervisors
        end

        def generate_duplicates_list
          duplicate_names = {}
          duplicate_name_orgs = {}
          @hypervisors.each do |hypervisor|
            next if @hosts.key?(hypervisor[:uuid])

            duplicate_name, org = duplicate_name(hypervisor, @candlepin_attributes[hypervisor[:uuid]])
            duplicate_names[duplicate_name] = hypervisor[:uuid]
            duplicate_name_orgs[duplicate_name] = org
          end

          [duplicate_names, duplicate_name_orgs]
        end

        def validate_host_organization(host, organization)
          if host.organization_id.nil? || host.organization_id != organization
            fail _("Host '%{name}' does not belong to an organization") % {:name => host.name} unless host.organization
          end
        end

        # extracts a single field from a given list og hypervisors data.
        def hypervisors_field(field, hypervisors = @hypervisors)
          hypervisors.map { |h| h[field] }.uniq
        end

        def name_for_host(organization, consumer)
          sanitized_name = ::Katello::Host::SubscriptionFacet.sanitize_name(consumer[:hypervisorId][:hypervisorId])
          "virt-who-#{sanitized_name}-#{organization.id}"
        end

        def duplicate_name(hypervisor, consumer)
          organization = @organizations[hypervisor[:organization_label]]
          [name_for_host(organization, consumer), organization]
        end

        def create_host_for_hypervisor(name, organization, location = nil)
          location ||= Location.default_host_subscribe_location!
          host = ::Host::Managed.new(:name => name, :organization => organization,
                                     :location => location, :managed => false, :enabled => false)
          host.save!
          host
        end

        def update_host(uuid, host)
          update_subscription_facet(uuid, host)
          update_host_name(uuid, host)
          host.save!
        end

        def update_host_name(uuid, host)
          # if the hypervisorId name pattern does not match that of the host, update the name
          consumer = @candlepin_attributes[uuid]
          return unless consumer

          expected_name = name_for_host(host.organization, consumer)
          if host.name != expected_name
            host.name = expected_name
          end
        end

        def update_subscription_facet(uuid, host)
          if @candlepin_attributes.key?(uuid)
            host.subscription_facet.candlepin_consumer.consumer_attributes = @candlepin_attributes[uuid]
            host.subscription_facet.import_database_attributes
            host.subscription_facet.save!
          end
        end

        def update_facts(uuid, host)
          if @candlepin_attributes.key?(uuid)
            ::Katello::Host::SubscriptionFacet.update_facts(host, @candlepin_attributes[uuid][:facts]) unless @candlepin_attributes[uuid][:facts].blank?
          end
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end
      end
    end
  end
end
