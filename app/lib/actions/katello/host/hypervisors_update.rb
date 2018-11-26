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
        end

        def finalize
          @hypervisors = input[:hypervisors]
          return unless @hypervisors

          User.as_anonymous_admin do
            load_resources

            @hosts.each do |uuid, host|
              update_subscription_facet(uuid, host)
            end
          end
        end

        # Loads all resources needed for refreshing subscription facet
        def load_resources
          @organizations = ::Organization.where(label: hypervisors_field(:organization_label)).map { |org| [org.label, org] }.to_h
          @hosts = {}

          load_hosts_by_uuid
          load_hosts_by_duplicate_name
          create_missing_hosts

          candlepin_data = ::Katello::Resources::Candlepin::Consumer.get_all(@hosts.keys)
          @candlepin_attributes = candlepin_data.map { |consumer| [consumer[:uuid], consumer] }.to_h
        end

        def load_hosts_by_uuid
          hosts_by_uuid = ::Host.eager_load(:subscription_facet).where(katello_subscription_facets: { uuid: hypervisors_field(:uuid) })
          hosts_by_uuid.each do |host|
            validate_host_organization(host, host.organization.try(:id))
          end
          @hosts.merge!(hosts_by_uuid.map { |host| [host.subscription_facet.uuid, host] }.to_h)
        end

        def load_hosts_by_duplicate_name
          duplicate_names, duplicate_name_orgs = generate_duplicates_list

          hosts_by_dup_name = ::Host.preload(:subscription_facet).where(name: duplicate_names.keys)

          hosts_by_dup_name.each do |host|
            validate_host_organization(host, duplicate_name_orgs[host.name].try(:id))
          end

          @hosts.merge!(hosts_by_dup_name.map { |host| [duplicate_names[host.name], host] }.to_h)
        end

        def create_missing_hosts
          # remaining hypervisors
          @hypervisors.each do |hypervisor|
            next if @hosts.key?(hypervisor[:uuid])
            duplicate_name, org = duplicate_name(hypervisor)
            @hosts[hypervisor[:uuid]] = create_host_for_hypervisor(duplicate_name, org)
          end
        end

        def generate_duplicates_list
          duplicate_names = {}
          duplicate_name_orgs = {}
          @hypervisors.each do |hypervisor|
            next if @hosts.key?(hypervisor[:uuid])

            duplicate_name, org = duplicate_name(hypervisor)
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

        def duplicate_name(hypervisor)
          organization = @organizations[hypervisor[:organization_label]]
          sanitized_name = ::Katello::Host::SubscriptionFacet.sanitize_name(hypervisor[:name])
          ["virt-who-#{sanitized_name}-#{organization.id}", organization]
        end

        def create_host_for_hypervisor(name, organization, location = nil)
          location ||= Location.default_host_subscribe_location!
          host = ::Host::Managed.new(:name => name, :organization => organization,
                                     :location => location, :managed => false, :enabled => false)
          host.save!
          host
        end

        def update_subscription_facet(uuid, host)
          host.subscription_facet ||= host.build_subscription_facet(uuid: uuid)
          if @candlepin_attributes.key?(uuid)
            host.subscription_facet.candlepin_consumer.consumer_attributes = @candlepin_attributes[uuid]
            host.subscription_facet.import_database_attributes
            host.subscription_facet.save!
            host.subscription_facet.update_subscription_status(@candlepin_attributes[uuid].try(:[], :entitlementStatus))
          end
          host.save!
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end
      end
    end
  end
end
