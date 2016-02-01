module Katello
  module Host
    class SubscriptionFacet < Katello::Model
      self.table_name = 'katello_subscription_facets'
      belongs_to :host, :inverse_of => :subscription_facet, :class_name => "::Host::Managed"

      has_many :activation_keys, :through => :subscription_facet_activation_keys, :class_name => "Katello::ActivationKey"
      has_many :subscription_facet_activation_keys, :class_name => "Katello::SubscriptionFacetActivationKey", :dependent => :destroy, :inverse_of => :subscription_facet

      validates :host, :presence => true, :allow_blank => false

      DEFAULT_TYPE = Glue::Candlepin::Consumer::SYSTEM

      def update_from_consumer_attributes(consumer_params)
        self.autoheal = consumer_params['autoheal'] unless consumer_params['autoheal'].blank?
        self.service_level = consumer_params['serviceLevel'] unless consumer_params['serviceLevel'].blank?
        self.release_version = consumer_params['releaseVer'] unless consumer_params['releaseVer'].blank?
        self.last_checkin = consumer_params['lastCheckin'] unless consumer_params['lastCheckin'].blank?
      end

      def consumer_attributes
        {
          :autoheal => autoheal,
          :serviceLevel => service_level,
          :releaseVer => release_version,
          :environment => {:id => self.candlepin_environment_id}
        }
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
      end

      def self.new_host_from_facts(facts, org, location)
        ::Host::Managed.new(:name => facts['network.hostname'], :organization => org, :location => location, :managed => false)
      end

      def self.update_facts(host, rhsm_facts)
        return if host.build?
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

      def self.find_or_create_host_for_hypervisor(name, organization, location = nil)
        location ||= Location.default_location
        host = find_host(name, organization)
        host = ::Host::Managed.new(:name => name, :organization => organization, :location => location,
                            :managed => false) unless host
        host
      end

      def remove_subscriptions(pools_with_quantities)
        entitlements = pools_with_quantities.map do |pool_with_quantities|
          candlepin_consumer.filter_entitlements(pool_with_quantities.pool.cp_id, pool_with_quantities.quantities)
        end

        ForemanTasks.sync_task(Actions::Katello::Host::RemoveSubscriptions, self.host, entitlements.flatten)
      end

      def self.find_host(name, organization)
        hosts = ::Host.where(:name => name)
        return nil if hosts.empty? #no host exists
        if hosts.where("organization_id = #{organization.id} OR organization_id is NULL").empty? #not in the correct org
          #TODO: http://projects.theforeman.org/issues/11532
          fail _("Host is currently registered to a different org, please migrate host to %s.") %  organization.name
        end
        hosts.first
      end

      def candlepin_consumer
        @candlepin_consumer ||= Katello::Candlepin::Consumer.new(self.uuid)
      end
    end
  end
end
