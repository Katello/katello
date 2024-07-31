module Katello
  module Host
    class SubscriptionFacet < Katello::Model
      audited :associated_with => :host, :associations => [:pools], :except => [:last_checkin]
      self.table_name = 'katello_subscription_facets'
      include Facets::Base
      include DirtyAssociations

      belongs_to :user, :inverse_of => :subscription_facets, :class_name => "::User"
      belongs_to :hypervisor_host, :class_name => "::Host::Managed"

      has_many :subscription_facet_activation_keys, :class_name => "Katello::SubscriptionFacetActivationKey", :dependent => :destroy, :inverse_of => :subscription_facet
      has_many :activation_keys, :through => :subscription_facet_activation_keys, :class_name => "Katello::ActivationKey"

      has_many :subscription_facet_purpose_addons, :class_name => "Katello::SubscriptionFacetPurposeAddon", :dependent => :destroy, :inverse_of => :subscription_facet
      has_many :purpose_addons, :class_name => "Katello::PurposeAddon", :through => :subscription_facet_purpose_addons

      has_many :subscription_facet_pools, :class_name => "Katello::SubscriptionFacetPool", :dependent => :delete_all, :inverse_of => :subscription_facet
      has_many :pools, :through => :subscription_facet_pools, :class_name => "Katello::Pool"

      has_many :subscription_facet_installed_products, :class_name => "Katello::SubscriptionFacetInstalledProduct", :dependent => :destroy, :inverse_of => :subscription_facet
      has_many :installed_products, :through => :subscription_facet_installed_products, :class_name => "Katello::InstalledProduct"

      has_many :compliance_reasons, :class_name => "Katello::ComplianceReason", :dependent => :destroy, :inverse_of => :subscription_facet

      validates :host, :presence => true, :allow_blank => false

      DEFAULT_TYPE = 'system'.freeze

      accepts_nested_attributes_for :installed_products, :purpose_addons

      dirty_has_many_associations :purpose_addons

      attr_accessor :facts

      DMI_UUID_ALLOWED_DUPS = ['', 'Not Settable', 'Not Present'].freeze
      DMI_UUID_OVERRIDE_PARAM = 'dmi_uuid_override'.freeze

      delegate :content_overrides, to: :candlepin_consumer, allow_nil: true

      def host_type
        host_facts = self.host.facts
        host_facts["virt::host_type"] || host_facts["hypervisor::type"]
      end

      def update_from_consumer_attributes(consumer_params)
        import_database_attributes(consumer_params)
        self.facts = consumer_params['facts'] unless consumer_params['facts'].blank?
      end

      def import_database_attributes(consumer_params = candlepin_consumer.consumer_attributes)
        update_hypervisor(consumer_params)
        update_guests(consumer_params)

        if consumer_params['facts']
          self.dmi_uuid = consumer_params['facts']['dmi.system.uuid']
        end

        self.autoheal = consumer_params['autoheal'] unless consumer_params['autoheal'].nil?
        self.service_level = consumer_params['serviceLevel'] unless consumer_params['serviceLevel'].nil?
        self.registered_at = consumer_params['created'] unless consumer_params['created'].blank?
        self.last_checkin = consumer_params['lastCheckin'] unless consumer_params['lastCheckin'].blank?
        self.update_installed_products(consumer_params['installedProducts']) if consumer_params.key?('installedProducts')
        self.purpose_role = consumer_params['role'] unless consumer_params['role'].nil?
        self.purpose_usage = consumer_params['usage'] unless consumer_params['usage'].nil?
        unless consumer_params['addOns'].nil?
          self.purpose_addon_ids = consumer_params['addOns'].map { |addon_name| ::Katello::PurposeAddon.find_or_create_by(name: addon_name).id }
        end

        unless consumer_params['releaseVer'].nil?
          release = consumer_params['releaseVer']
          release = release['releaseVer'] if release.is_a?(Hash)
          self.release_version = release
        end
      end

      def update_installed_products(consumer_installed_product_list)
        self.installed_products = consumer_installed_product_list.map do |consumer_installed_product|
          InstalledProduct.find_or_create_from_consumer(consumer_installed_product)
        end
      end

      def update_compliance_reasons(reasons)
        reasons = Katello::Candlepin::Consumer.friendly_compliance_reasons(reasons)

        existing = self.compliance_reasons.pluck(:reason)
        to_delete = existing - reasons
        to_create = reasons - existing
        self.compliance_reasons.where(:reason => to_delete).destroy_all if to_delete.any?
        to_create.each { |reason| self.compliance_reasons.create(:reason => reason) }
      end

      def virtual_guests
        ::Host.joins(:subscription_facet).where("#{self.class.table_name}.hypervisor_host_id" => self.host_id)
      end

      def virtual_guest_uuids
        virtual_guests.pluck("#{Katello::Host::SubscriptionFacet.table_name}.uuid")
      end

      def update_hypervisor(consumer_params = candlepin_consumer.consumer_attributes)
        if consumer_params.try(:[], 'type').try(:[], 'label') == 'hypervisor'
          self.hypervisor = true
        elsif !consumer_params.try(:[], 'guestIds').empty?
          self.hypervisor = true
        elsif !candlepin_consumer.virtual_guests.empty?
          # Check by calling out to Candlepin last for efficiency
          self.hypervisor = true
        end
      end

      def update_guests(consumer_params)
        if self.hypervisor
          if !consumer_params.try(:[], 'guestIds').empty?
            guest_ids = consumer_params['guestIds'].map do |id|
              case id
              when Hash
                id['guestId'].downcase
              when String
                id.downcase
              end
            end

            guest_ids = FactValue.where("lower(value) IN (?)", guest_ids).
                                  where(:fact_name_id => FactName.where(:name => 'virt::uuid')).
                                  pluck(:host_id)
          else
            guest_ids = self.candlepin_consumer.virtual_guests.pluck(:id)
          end

          subscription_facets = SubscriptionFacet.where(:host_id => guest_ids).
                                                  where("hypervisor_host_id != ? OR hypervisor_host_id is NULL", self.host.id)
          subscription_facets.update_all(:hypervisor_host_id => self.host.id)
        elsif (virtual_host = self.candlepin_consumer.virtual_host)
          self.hypervisor_host = virtual_host
        end
      end

      def consumer_attributes
        attrs = {
          :autoheal => autoheal,
          :usage => purpose_usage,
          :role => purpose_role,
          :addOns => purpose_addons.pluck(:name),
          :serviceLevel => service_level,
          :releaseVer => release_version,
          :environments => self.candlepin_environments,
          :installedProducts => self.installed_products.map(&:consumer_attributes),
          :guestIds => virtual_guest_uuids
        }
        attrs[:facts] = facts if facts
        HashWithIndifferentAccess.new(attrs)
      end

      def candlepin_environments
        if self.host.content_facet
          self.host.content_facet.content_view_environments.map do |cve|
            { :id => cve.content_view.cp_environment_id(cve.lifecycle_environment) }
          end
        else
          self.host.organization.default_content_view.cp_environment_id(self.host.organization.library)
        end
      end

      def candlepin_environments_cp_ids
        candlepin_environments.map { |e| e[:id] }
      end

      def content_view_environments
        self.host.content_facet.try(:content_view_environments)
      end

      def consumer_cve_order_from_candlepin
        Katello::Resources::Candlepin::Consumer.get(uuid)['environments'].map { |e| e['id'] }
      end

      def cves_ordered_correctly?
        consumer_cve_order_from_candlepin == candlepin_environments_cp_ids
      end

      def organization
        self.host.organization
      end

      def dmi_uuid_override
        HostParameter.find_by(name: DMI_UUID_OVERRIDE_PARAM, host: host)
      end

      def update_dmi_uuid_override(host_uuid = nil)
        host_uuid ||= SecureRandom.uuid
        param = HostParameter.find_or_create_by(name: DMI_UUID_OVERRIDE_PARAM, host: host)
        param.update!(value: host_uuid)
        param
      end

      def self.override_dmi_uuid?(host_uuid)
        Setting[:host_dmi_uuid_duplicates].include?(host_uuid)
      end

      def self.new_host_from_facts(facts, org, location)
        name = propose_name_from_facts(facts)
        ::Host::Managed.new(:name => name, :organization => org, :location => location, :managed => false)
      end

      def self.update_facts(host, rhsm_facts)
        return if host.build? || rhsm_facts.nil?
        rhsm_facts[:_type] = RhsmFactName::FACT_TYPE
        rhsm_facts[:_timestamp] = Time.now.to_s
        if ignore_os?(host.operatingsystem, rhsm_facts)
          rhsm_facts[:ignore_os] = true
        end
        ::HostFactImporter.new(host).import_facts(rhsm_facts)
      end

      def self.ignore_os?(host_os, rhsm_facts)
        if host_os.nil?
          return false
        end

        name = rhsm_facts['distribution.name']
        version = rhsm_facts['distribution.version']
        major, minor = version&.split('.')
        return host_os.name == 'CentOS' &&
          !host_os.major.nil? &&
          name == 'CentOS' &&
          minor.blank? &&
          host_os.major == major
      end

      def self.propose_name_from_facts(facts)
        setting_fact = Setting[:register_hostname_fact]
        if !setting_fact.blank? && facts[setting_fact] && facts[setting_fact] != 'localhost'
          facts[setting_fact]
        else
          Rails.logger.warn(_("register_hostname_fact set for %s, but no fact found, or was localhost.") % setting_fact) unless setting_fact.blank?
          [facts['network.fqdn'], facts['network.hostname-override'], facts['network.hostname']].find { |name| !name.blank? && name != 'localhost' }
        end
      end

      def self.propose_custom_fact(facts)
        setting_fact = Setting[:register_hostname_fact]
        only_use_custom_fact = Setting[:register_hostname_fact_strict_match]

        if !setting_fact.blank? && !facts[setting_fact].blank? && (only_use_custom_fact || ::Host.where(:name => setting_fact.downcase).any?)
          facts[setting_fact]
        end
      end

      def self.propose_existing_hostname(facts)
        if propose_custom_fact(facts)
          name = propose_custom_fact(facts)
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

      def products
        Katello::Product.joins(:subscriptions => {:pools => :subscription_facets}).where("#{Katello::Host::SubscriptionFacet.table_name}.id" => self.id).enabled.uniq
      end

      def remove_subscriptions(pools_with_quantities)
        ForemanTasks.sync_task(Actions::Katello::Host::RemoveSubscriptions, self.host, pools_with_quantities)
      end

      def self.sanitize_name(name)
        name.gsub('_', '-').chomp('.').downcase
      end

      def unsubscribed_hypervisor?
        self.hypervisor && !self.candlepin_consumer.entitlements?
      end

      def candlepin_consumer
        @candlepin_consumer ||= Katello::Candlepin::Consumer.new(self.uuid, self.host.organization.label)
      end

      def backend_update_needed?
        %w(release_version service_level autoheal purpose_role purpose_usage purpose_addon_ids).each do |method|
          if self.send("#{method}_changed?")
            Rails.logger.debug("backend_update_needed: subscription facet #{method} changed")
            return true
          end
        end
        facet = self.host&.content_facet
        if facet&.cves_changed? && !facet.new_record?
          Rails.logger.debug("backend_update_needed: content facet CVEs changed")
          return true
        end
        false
      end

      def self.populate_fields_from_facts(host, parser, _type, _source_proxy)
        has_convert2rhel = parser.facts.key?('conversions.env.CONVERT2RHEL_THROUGH_FOREMAN')
        # Add in custom convert2rhel fact if system was converted using convert2rhel through Katello
        # We want the value nil unless the custom fact is present otherwise we get a 0 in the database which if debugging
        # might make you think it was converted2rhel but not with satellite, that is why I have the tenary below.
        facet = host.subscription_facet || host.build_subscription_facet
        facet.attributes = {
          convert2rhel_through_foreman: has_convert2rhel ? ::Foreman::Cast.to_bool(parser.facts['conversions.env.CONVERT2RHEL_THROUGH_FOREMAN']) : nil
        }.compact
        facet.save unless facet.new_record?
      end

      private

      def update_status(status_class, **args)
        status = host.get_status(status_class)
        if args[:status_override].nil?
          host.get_status(status_class).refresh!
        else
          status.status = status.to_status(**args)
          status.save!
        end
      end
    end
  end
end
