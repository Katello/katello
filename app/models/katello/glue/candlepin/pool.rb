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
          :variant, :suggested_quantity, :support_type, :product_id, :type, :upstream_entitlement_id, :roles, :usage,
          :initializer => :pool_facts

        lazy_accessor :name, :support_level, :org, :sockets, :cores, :instance_multiplier,
          :initializer => :subscription_facts

        lazy_accessor :active, :initializer => lambda { |_s| self.pool_facts["activeSubscription"] }

        lazy_accessor :available, :initializer => lambda { |_s| self.quantity_available }

        lazy_accessor :backend_data, :initializer => lambda { |_s| self.class.candlepin_data(self.cp_id) }
      end
    end

    module ClassMethods
      def candlepin_data(cp_id, rescue_gone = false)
        Katello::Resources::Candlepin::Pool.find(cp_id)
      rescue Katello::Errors::CandlepinPoolGone => e
        raise e unless rescue_gone

        if (pool_id = ::Katello::Pool.find_by_cp_id(cp_id)&.id)
          Katello::EventQueue.push_event(::Katello::Events::DeletePool::EVENT_TYPE, pool_id)
          Rails.logger.warn("Sending pool delete event for missing candlepin pool cp_id=#{cp_id}")
        end
        {}
      end

      def get_for_owner(organization)
        Katello::Resources::Candlepin::Pool.get_for_owner(organization, true)
      end

      def import_pool(cp_pool_id)
        Katello::Logging.time("import candlepin pool", data: { cp_id: cp_pool_id }) do
          json = candlepin_data(cp_pool_id)

          org = Organization.find_by(label: json['owner']['key'])
          fail("Organization with label #{json['owner']['key']} wasn't found while importing Candlepin pool") unless org

          pool = import_candlepin_record(record: json, organization: org)
          pool.backend_data = json
          pool.import_data
        end
      end

      def import_candlepin_records(pools, org)
        # Skip import of pools that were associated with an orphaned custom product
        pools = pools.reject { |cp_pool| ::Katello::Glue::Provider.orphaned_custom_product?(cp_pool['productId'], org) }
        super(pools, org)
      end

      def import_candlepin_record(record:, organization:)
        subscription = determine_subscription(
          product_id: record['productId'],
          source_stack_id: record['sourceStackId'],
          organization: organization
        )

        super do |attrs|
          attrs[:subscription] = subscription
        end
      end

      def determine_subscription(organization:, product_id: nil, source_stack_id: nil)
        if source_stack_id
          self.stacking_subscription(organization, source_stack_id)
          # isn't it an error if we have a sourceStackID but no stacking subscription?
        else
          ::Katello::Subscription.find_by(:cp_id => product_id, organization: organization)
        end
      end

      def stacking_subscription(org, stacking_id)
        subscription = ::Katello::Subscription.find_by(:organization_id => org.id, :cp_id => stacking_id)
        if subscription.nil?
          found_product = ::Katello::Resources::Candlepin::Product.find_for_stacking_id(org.label, stacking_id)
          subscription = ::Katello::Subscription.find_by(:organization_id => org.id, :cp_id => found_product['id']) if found_product
        end
        subscription
      end
    end

    module InstanceMethods
      def import_lazy_attributes
        json = self.class.candlepin_data(self.cp_id)

        return {} if json.blank?

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

        subscription.backend_data["attributes"].map { |attr| json[attr["name"].underscore.to_sym] = attr["value"] }
        json
      end

      def provider?(organization)
        providers = self.subscription.products.collect do |provider|
          Katello::Provider.where(:id => provider.provider_id, :organization_id => organization.id).first
        end
        providers.any?
      end

      # rubocop:disable Metrics/CyclomaticComplexity
      def import_data
        pool_attributes = {}.with_indifferent_access
        pool_json = self.backend_data

        product_attributes = pool_json["productAttributes"] + pool_json["attributes"]
        product_attributes.map { |attr| pool_attributes[attr["name"].underscore.to_sym] = attr["value"] }

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

        pool_attributes[:virt_who] = (pool_attributes['virt_limit'].present? && pool_attributes['virt_limit'] != "0")

        pool_attributes['stack_id'] = pool_json['stackId']
        exceptions = pool_attributes.keys.map(&:to_sym) - self.attribute_names.map(&:to_sym)
        self.update(pool_attributes.except!(*exceptions))
        self.save!
        self.create_product_associations
      end
      # rubocop:enable

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
    end
  end
end
