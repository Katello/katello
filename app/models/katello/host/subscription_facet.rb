module Katello
  module Host
    class SubscriptionFacet < Katello::Model
      self.table_name = 'katello_subscription_facets'
      belongs_to :host, :inverse_of => :subscription_facet, :class_name => "::Host::Managed"

      has_many :activation_keys, :through => :subscription_facet_activation_keys, :class_name => "Katello::ActivationKey"
      has_many :subscription_facet_activation_keys, :class_name => "Katello::SubscriptionFacetActivationKey", :dependent => :destroy, :inverse_of => :subscription_facet

      validates :host, :presence => true, :allow_blank => false

      DEFAULT_TYPE = Glue::Candlepin::Consumer::SYSTEM

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
        ::Host::Managed.new(:name => facts['network.hostname'], :organization => org, :location => location, :managed => false)
      end

      def self.update_facts(host, rhsm_facts)
        return if host.build? || rhsm_facts.nil?
        rhsm_facts[:_type] = RhsmFactName::FACT_TYPE
        rhsm_facts[:_timestamp] = DateTime.now.to_s
        host.import_facts(rhsm_facts)
      end

      def self.find_or_create_host(name, organization, rhsm_params)
        host = find_host(name, organization)
        host = Katello::Host::SubscriptionFacet.new_host_from_facts(rhsm_params[:facts], organization,
                                          Location.default_location) unless host
        host.organization = organization unless host.organization
        host
      end

      def remove_subscriptions(pools_with_quantities)
        entitlements = pools_with_quantities.map do |pool_with_quantities|
          candlepin_consumer.filter_entitlements(pool_with_quantities.pool.cp_id, pool_with_quantities.quantities)
        end

        ForemanTasks.sync_task(Actions::Katello::Host::RemoveSubscriptions, self.host, entitlements.flatten)
      end

      def self.find_host(name, organization)
        hosts = ::Host.where(:name => name.downcase)
        return nil if hosts.empty? #no host exists
        if hosts.where("organization_id = #{organization.id} OR organization_id is NULL").empty? #not in the correct org
          #TODO: http://projects.theforeman.org/issues/11532
          fail _("Host is currently registered to a different org, please migrate host to %s.") % organization.name
        end
        hosts.first
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
