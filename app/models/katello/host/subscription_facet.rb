module Katello
  module Host
    class SubscriptionFacet < Katello::Model
      self.table_name = 'katello_subscription_facets'
      belongs_to :host, :inverse_of => :subscription_facet, :class_name => "::Host::Managed"
      belongs_to :user, :inverse_of => :subscription_facets, :class_name => "::User"

      has_many :activation_keys, :through => :subscription_facet_activation_keys, :class_name => "Katello::ActivationKey"
      has_many :subscription_facet_activation_keys, :class_name => "Katello::SubscriptionFacetActivationKey", :dependent => :destroy, :inverse_of => :subscription_facet

      validates :host, :presence => true, :allow_blank => false

      DEFAULT_TYPE = 'system'.freeze

      attr_accessor :installed_products, :facts, :hypervisor_guest_uuids

      def update_from_consumer_attributes(consumer_params)
        import_database_attributes(consumer_params)
        self.installed_products = consumer_params['installedProducts'] unless consumer_params['installedProducts'].blank?
        self.hypervisor_guest_uuids = consumer_params['guestIds'] unless consumer_params['hypervisor_guest_uuids'].blank?
        self.facts = consumer_params['facts'] unless consumer_params['facts'].blank?
      end

      def import_database_attributes(consumer_params)
        self.autoheal = consumer_params['autoheal'] unless consumer_params['autoheal'].blank?
        self.service_level = consumer_params['serviceLevel'] unless consumer_params['serviceLevel'].blank?
        self.registered_at = consumer_params['created'] unless consumer_params['created'].blank?
        self.last_checkin = consumer_params['lastCheckin'] unless consumer_params['lastCheckin'].blank?

        unless consumer_params['releaseVer'].blank?
          release = consumer_params['releaseVer']
          release = release['releaseVer'] if release.is_a?(Hash)
          self.release_version = release
        end
      end

      def consumer_attributes
        attrs = {
          :autoheal => autoheal,
          :serviceLevel => service_level,
          :releaseVer => release_version,
          :environment => {:id => self.candlepin_environment_id}
        }
        attrs[:facts] = facts if facts
        attrs[:guestIds] = hypervisor_guest_uuids if hypervisor_guest_uuids
        if installed_products
          attrs[:installedProducts] = installed_products.collect do |installed_product|
            product = {
              :productName => installed_product[:product_name],
              :productId => installed_product[:product_id]
            }
            product[:arch] = installed_product[:arch] if installed_product[:arch]
            product[:version] = installed_product[:version] if installed_product[:version]
            product
          end
        end
        attrs
      end

      def candlepin_environment_id
        if self.host.content_facet
          self.host.content_facet.content_view.cp_environment_id(self.host.content_facet.lifecycle_environment)
        else
          self.host.organization.default_content_view.cp_environment_id(self.host.organization.library)
        end
      end

      def update_subscription_status
        host.get_status(::Katello::SubscriptionStatus).refresh!
        host.refresh_global_status!
      end

      def self.new_host_from_facts(facts, org, location)
        name = propose_name_from_facts(facts)
        ::Host::Managed.new(:name => name, :organization => org, :location => location, :managed => false)
      end

      def self.update_facts(host, rhsm_facts)
        return if host.build? || rhsm_facts.nil?
        rhsm_facts[:_type] = RhsmFactName::FACT_TYPE
        rhsm_facts[:_timestamp] = DateTime.now.to_s
        host.import_facts(rhsm_facts)
      end

      def self.find_or_create_host(organization, rhsm_params)
        host = find_host(rhsm_params[:facts], organization)
        host = Katello::Host::SubscriptionFacet.new_host_from_facts(rhsm_params[:facts], organization,
                                          Location.default_location) unless host
        host.organization = organization unless host.organization
        host
      end

      def self.propose_name_from_facts(facts)
        setting_fact = Setting[:register_hostname_fact]
        if !setting_fact.blank? && facts[setting_fact]
          facts[setting_fact]
        else
          Rails.logger.warn(_("register_hostname_fact set for %s, but no fact found.") % setting_fact) unless setting_fact.blank?
          [facts['network.fqdn'], facts['network.hostname-override'], facts['network.hostname']].find { |name| !name.blank? }
        end
      end

      def self.propose_existing_hostname(facts)
        setting_fact = Setting[:register_hostname_fact]
        if !setting_fact.blank? && !facts[setting_fact].blank? && ::Host.where(:name => setting_fact.downcase).any?
          name = facts[setting_fact]
        elsif ::Host.where(:name => facts['network.hostname'].downcase).any?
          name = facts['network.hostname']
        elsif !facts['network.fqdn'].blank? && ::Host.where(:name => facts['network.fqdn'].downcase).any?
          name = facts['network.fqdn']
        elsif !facts['network.hostname-override'].blank? && ::Host.where(:name => facts['network.hostname-override'].downcase).any?
          name = facts['network.hostname-override']
        else
          name = facts['network.hostname'] #fallback to default, even if it doesn't exist
        end

        name.downcase
      end

      def remove_subscriptions(pools_with_quantities)
        ForemanTasks.sync_task(Actions::Katello::Host::RemoveSubscriptions, self.host, pools_with_quantities)
      end

      def self.find_host(facts, organization)
        host_name = propose_existing_hostname(facts)
        hosts = ::Host.where(:name => host_name)

        return nil if hosts.empty? #no host exists
        if hosts.where("organization_id = #{organization.id} OR organization_id is NULL").empty? #not in the correct org
          #TODO: http://projects.theforeman.org/issues/11532
          fail _("Host with name %{host_name} is currently registered to a different org, please migrate host to %{org_name}.") %
                   {:org_name => organization.name, :host_name => host_name }
        end
        hosts.first
      end

      def self.sanitize_name(name)
        name.gsub('_', '-').chomp('.').downcase
      end

      def candlepin_consumer
        @candlepin_consumer ||= Katello::Candlepin::Consumer.new(self.uuid)
      end

      def backend_update_needed?
        return true if self.installed_products || self.hypervisor_guest_uuids

        %w(release_version service_level autoheal).each do |method|
          return true if self.send("#{method}_changed?")
        end
        if self.host.content_facet
          return true if (self.host.content_facet.content_view_id_changed? || self.host.content_facet.lifecycle_environment_id_changed?)
        end
        false
      end
    end
  end
end
