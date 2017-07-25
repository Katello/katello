module Katello
  module Glue::Candlepin::Pool
    def self.included(base)
      base.send :include, LazyAccessor
      base.send :include, InstanceMethods
      base.send :extend, ClassMethods

      base.class_eval do
        lazy_accessor :pool_facts, :initializer => lambda { |_s| self.import_lazy_attributes }
        lazy_accessor :subscription_facts, :initializer => lambda { |_s| self.subscription ? self.subscription.attributes : {} }

        lazy_accessor :pool_derived, :owner, :source_pool_id, :host_id, :virt_limit, :arch, :description,
          :product_family, :variant, :suggested_quantity, :support_type, :product_id, :type,
          :initializer => :pool_facts

        lazy_accessor :name, :support_level, :org, :sockets, :cores, :stacking_id, :instance_multiplier,
          :initializer => :subscription_facts

        lazy_accessor :active, :initializer => lambda { |_s| self.pool_facts["activeSubscription"] }

        lazy_accessor :available, :initializer => lambda { |_s| self.quantity_available }
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
        pool = nil
        ::Katello::Util::Support.active_record_retry do
          pool = Katello::Pool.where(:cp_id => cp_pool_id).first_or_create
        end
        pool.import_data(index_hosts)
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
          when 'requires_host'
            json["host_id"] = attr['value']
          when 'virt_limit'
            json["virt_limit"] = attr['value'].to_i
          when 'support_type'
            json['support_type'] = attr['value']
          end
        end

        if json["calculatedAttributes"]
          json["calculatedAttributes"].each do |key|
            json["suggested_quantity"] = json["calculatedAttributes"]["suggested_quantity"].to_i if key == 'suggested_quantity'
          end
        end

        json["product_id"] = json["productId"] if json["productId"]

        if self.subscription
          subscription.backend_data["product"]["attributes"].map { |attr| json[attr["name"].underscore.to_sym] = attr["value"] }
        end
        json
      end

      def provider?(organization)
        providers = self.subscription.products.collect do |provider|
          Katello::Provider.where(:id => provider.provider_id, :organization_id => organization.id).first
        end
        providers.any?
      end

      def backend_data
        self.class.candlepin_data(self.cp_id)
      end

      def stacking_subscription(org_label, stacking_id)
        org = Organization.find_by(:label => org_label)
        subscription = ::Katello::Subscription.find_by(:organization_id => org.id, :product_id => stacking_id)
        if subscription.nil?
          found_product = ::Katello::Resources::Candlepin::Product.find_for_stacking_id(org_label, stacking_id)
          subscription = ::Katello::Subscription.find_by(:organization_id => org.id, :product_id => found_product['id']) if found_product
        end
        subscription
      end

      # rubocop:disable MethodLength
      def import_data(index_hosts = true)
        pool_attributes = {}.with_indifferent_access
        pool_json = self.backend_data
        product_attributes = pool_json["productAttributes"] + pool_json["attributes"]

        product_attributes.map { |attr| pool_attributes[attr["name"].underscore.to_sym] = attr["value"] }

        if pool_json["sourceStackId"]
          subscription = stacking_subscription(pool_json['owner']['key'], pool_json["sourceStackId"])
        else
          subscription = ::Katello::Subscription.find_by(:cp_id => pool_json["subscriptionId"])
        end

        pool_attributes[:subscription_id] = subscription.id if subscription

        %w(accountNumber contractNumber quantity startDate endDate accountNumber consumed).each do |json_attribute|
          pool_attributes[json_attribute.underscore] = pool_json[json_attribute]
        end
        pool_attributes[:pool_type] = pool_json["type"] if pool_json.key?("type")

        if pool_attributes.key?(:multi_entitlement)
          pool_attributes[:multi_entitlement] = pool_attributes[:multi_entitlement] == "yes" ? true : false
        end

        if pool_attributes.key?(:virtual)
          pool_attributes[:virt_only] = pool_attributes["virtual"] == 'true' ? true : false
        end
        pool_attributes[:host_id] = pool_attributes["requiresHost"] if pool_attributes.key?("requiresHost")

        if pool_attributes.key?(:unmapped_guests_only) && pool_attributes[:unmapped_guests_only] == 'true'
          pool_attributes[:unmapped_guest] = true
        end

        if subscription.try(:redhat?)
          pool_attributes[:virt_who] = pool_attributes['virt_limit'] != "0" && pool_attributes['virt_limit'].present?
        else
          pool_attributes[:virt_who] = false
        end

        exceptions = pool_attributes.keys.map(&:to_sym) - self.attribute_names.map(&:to_sym)
        self.update_attributes(pool_attributes.except!(*exceptions))
        self.save!
        self.create_activation_key_associations
        self.import_hosts if index_hosts
      end

      def import_hosts
        entitlements = Resources::Candlepin::Pool.entitlements(self.cp_id, ["consumer.uuid"])
        uuids = entitlements.map { |ent| ent["consumer"]["uuid"] }
        sub_facets = Katello::Host::SubscriptionFacet.where(:uuid => uuids)
        sub_facet_ids = sub_facets.pluck(:id)
        sub_facet_ids.each do |sub_facet_id|
          Katello::SubscriptionFacetPool.where(:pool_id => self.id, :subscription_facet_id => sub_facet_id).first_or_create
        end
        existing_associations = Katello::SubscriptionFacetPool.where(:pool_id => self.id)
        correct_associations = Katello::SubscriptionFacetPool.where(:pool_id => self.id, :subscription_facet_id => sub_facet_ids)
        (existing_associations - correct_associations).map(&:destroy)
      end

      def hosts
        ::Host.where(:id => self.subscription_facets.pluck(:host_id))
      end

      def create_activation_key_associations
        keys = Resources::Candlepin::ActivationKey.get(nil, "?include=id&include=pools.pool.id")
        activation_key_ids = keys.collect do |key|
          key['id'] if key['pools'].present? && key['pools'].any? { |pool| pool['pool'].try(:[], 'id') == cp_id }
        end
        related_keys = ::Katello::ActivationKey.where(:cp_id => activation_key_ids.compact)
        related_keys.each do |key|
          Katello::PoolActivationKey.where(:activation_key_id => key.id, :pool_id => self.id).first_or_create
        end
      end

      def hypervisor
        ::Katello::Host::SubscriptionFacet.find_by(:uuid => host_id).try(:host) if host_id
      end
    end
  end
end
