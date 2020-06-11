module Katello
  module Glue::Candlepin::Pool
    def self.included(base)
      base.send :include, LazyAccessor
      base.send :include, InstanceMethods
      base.send :extend, ClassMethods

      base.class_eval do
        lazy_accessor :pool_facts, :initializer => lambda { |_s| self.import_lazy_attributes }
        lazy_accessor :subscription_facts, :initializer => lambda { |_s| self.subscription ? self.subscription.attributes : {} }

        lazy_accessor :pool_derived, :owner, :source_pool_id, :virt_limit, :arch, :description, :product_family,
          :variant, :suggested_quantity, :support_type, :product_id, :type, :upstream_entitlement_id, :role, :usage, :addons,
          :initializer => :pool_facts

        lazy_accessor :name, :support_level, :org, :sockets, :cores, :instance_multiplier,
          :initializer => :subscription_facts

        lazy_accessor :active, :initializer => lambda { |_s| self.pool_facts["activeSubscription"] }

        lazy_accessor :available, :initializer => lambda { |_s| self.quantity_available }

        lazy_accessor :backend_data, :initializer => lambda { |_s| self.class.candlepin_data(self.cp_id) }
      end
    end

    module ClassMethods
      def candlepin_data(cp_id)
        Katello::Resources::Candlepin::Pool.find(cp_id)
      end

      def get_for_owner(organization)
        Katello::Resources::Candlepin::Pool.get_for_owner(organization, true)
      end

      def import_pool(cp_pool_id, index_hosts = true)
        json = candlepin_data(cp_pool_id)
        ::Katello::Util::Support.active_record_retry do
          pool = Katello::Pool.where(:cp_id => cp_pool_id, :organization => Organization.find_by(:label => json['owner']['key'])).first_or_create
          pool.backend_data = json
          pool.import_data(index_hosts)
        end
      end

      def stacking_subscription(org_label, stacking_id)
        org = Organization.find_by(:label => org_label)
        subscription = ::Katello::Subscription.find_by(:organization_id => org.id, :cp_id => stacking_id)
        if subscription.nil?
          found_product = ::Katello::Resources::Candlepin::Product.find_for_stacking_id(org_label, stacking_id)
          subscription = ::Katello::Subscription.find_by(:organization_id => org.id, :cp_id => found_product['id']) if found_product
        end
        subscription
      end
    end

    module InstanceMethods
      def import_lazy_attributes
        json = self.backend_data

        pool_attributes = json["attributes"] + json["productAttributes"]
        json["virt_only"] = false
        pool_attributes.each do |attr|
          json[attr["name"]] = attr["value"]
          case attr["name"]
          when 'virt_limit'
            json["virt_limit"] = attr['value'].to_i
          when 'support_type'
            json['support_type'] = attr['value']
          end
        end

        json["calculatedAttributes"]&.each do |key|
          json["suggested_quantity"] = json["calculatedAttributes"]["suggested_quantity"].to_i if key == 'suggested_quantity'
        end

        json["product_id"] = json["productId"] if json["productId"]
        json["upstream_entitlement_id"] = json["upstreamEntitlementId"]

        if self.subscription
          subscription.backend_data["attributes"].map { |attr| json[attr["name"].underscore.to_sym] = attr["value"] }
        end
        json
      end

      def provider?(organization)
        providers = self.subscription.products.collect do |provider|
          Katello::Provider.where(:id => provider.provider_id, :organization_id => organization.id).first
        end
        providers.any?
      end

      # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
      def import_data(index_hosts_and_activation_keys = false)
        pool_attributes = {}.with_indifferent_access
        pool_json = self.backend_data

        self.organization ||= Organization.find_by(:label => pool_json['owner']['key'])
        product_attributes = pool_json["productAttributes"] + pool_json["attributes"]

        product_attributes.map { |attr| pool_attributes[attr["name"].underscore.to_sym] = attr["value"] }

        if pool_json["sourceStackId"]
          subscription = Pool.stacking_subscription(pool_json['owner']['key'], pool_json["sourceStackId"])
        else
          subscription = ::Katello::Subscription.find_by(:cp_id => pool_json["productId"])
        end

        pool_attributes[:subscription_id] = subscription.id if subscription

        %w(accountNumber contractNumber quantity startDate endDate accountNumber consumed).each do |json_attribute|
          pool_attributes[json_attribute.underscore] = pool_json[json_attribute]
        end
        pool_attributes[:pool_type] = pool_json["type"] if pool_json.key?("type")
        pool_attributes[:upstream_pool_id] = pool_json["upstreamPoolId"] if pool_json.key?("upstreamPoolId")

        if pool_attributes.key?(:multi_entitlement)
          pool_attributes[:multi_entitlement] = pool_attributes[:multi_entitlement] == "yes"
        end

        if pool_attributes.key?(:virtual)
          pool_attributes[:virt_only] = pool_attributes["virtual"] == 'true'
        end

        if pool_attributes.key?("requires_host")
          pool_attributes[:hypervisor_id] = ::Katello::Host::SubscriptionFacet.find_by(:uuid => pool_attributes["requires_host"])
                                                                              .try(:host_id)
        end

        if pool_attributes.key?(:unmapped_guests_only) && pool_attributes[:unmapped_guests_only] == 'true'
          pool_attributes[:unmapped_guest] = true
        end

        if subscription.try(:redhat?)
          pool_attributes[:virt_who] = pool_attributes['virt_limit'] != "0" && pool_attributes['virt_limit'].present?
        else
          pool_attributes[:virt_who] = false
        end

        pool_attributes['stack_id'] = pool_json['stackId']
        exceptions = pool_attributes.keys.map(&:to_sym) - self.attribute_names.map(&:to_sym)
        self.update(pool_attributes.except!(*exceptions))
        self.save!
        self.create_activation_key_associations if index_hosts_and_activation_keys
        self.create_product_associations
        self.import_hosts if index_hosts_and_activation_keys
      end
      # rubocop:enable Metrics/MethodLength,Metrics/AbcSize

      def create_product_associations
        products = self.backend_data["providedProducts"] + self.backend_data["derivedProvidedProducts"]
        cp_product_ids = products.map { |product| product["productId"] }
        cp_product_ids << self.subscription.cp_id if self.subscription

        cp_product_ids.each do |cp_id|
          product = ::Katello::Product.where(:cp_id => cp_id, :organization_id => self.organization.id)
          if product.any?
            ::Katello::Util::Support.active_record_retry do
              ::Katello::PoolProduct.where(:pool_id => self.id, :product_id => product.first.id).first_or_create
            end
          end
        end
      end

      def import_hosts
        uuids = Resources::Candlepin::Pool.consumer_uuids(self.cp_id)

        sub_facet_ids_from_cp, host_ids_from_cp = Katello::Host::SubscriptionFacet.where('uuid in (?)', uuids).pluck([:id, :host_id]).transpose
        sub_facet_ids_from_cp ||= []
        host_ids_from_cp ||= []

        sub_facet_ids_from_pool_table = Katello::SubscriptionFacetPool.where(:pool_id => self.id).select(:subscription_facet_id).pluck(:subscription_facet_id)
        host_ids_from_pool_table = Katello::Host::SubscriptionFacet.where(:id => sub_facet_ids_from_pool_table).pluck(:host_id)

        entries_to_add = sub_facet_ids_from_cp - sub_facet_ids_from_pool_table
        unless entries_to_add.empty?
          ActiveRecord::Base.transaction do
            entries_to_add.each do |sub_facet_id|
              query = "INSERT INTO #{Katello::SubscriptionFacetPool.table_name} (pool_id, subscription_facet_id) VALUES (#{self.id}, #{sub_facet_id})"
              ActiveRecord::Base.connection.execute(query)
            end
          end
        end

        entries_to_remove = sub_facet_ids_from_pool_table - sub_facet_ids_from_cp
        Katello::SubscriptionFacetPool.where(:pool_id => self.id, :subscription_facet_id => entries_to_remove).delete_all
        self.import_audit_record(host_ids_from_pool_table, host_ids_from_cp)
      end

      def import_managed_associations
        Katello::Logging.time("Imported host associations") do
          import_hosts
        end

        Katello::Logging.time("Imported activation key associations") do
          create_activation_key_associations
        end
      end

      def hosts
        ::Host.where(:id => self.subscription_facets.pluck(:host_id))
      end

      def create_activation_key_associations
        keys = Rails.cache.fetch("#{organization.label}/activation_keys_id_pool_id", expires_in: 2.minutes) do
          Resources::Candlepin::ActivationKey.get(nil, "?include=id&include=pools.pool.id", organization.label)
        end
        activation_key_ids = keys.collect do |key|
          key['id'] if key['pools'].present? && key['pools'].any? { |pool| pool['pool'].try(:[], 'id') == cp_id }
        end
        related_keys = ::Katello::ActivationKey.where(:cp_id => activation_key_ids.compact)
        related_keys.each do |key|
          Katello::PoolActivationKey.where(:activation_key_id => key.id, :pool_id => self.id).first_or_create
        end
      end
    end
  end
end
