module Katello
  module Glue::Candlepin::Pool
    IMPORT_ROOT_ATTRIBUTES = %w(accountNumber contractNumber quantity startDate endDate upstreamPoolId upstreamEntitlementId).freeze
    IMPORT_ATTRIBUTES = %w(ram arch support_type roles usage description).freeze

    def self.included(base)
      base.send :include, LazyAccessor
      base.send :include, InstanceMethods
      base.send :extend, ClassMethods

      base.class_eval do
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
      def import_data
        pool_attributes = {}
        pool_json = self.backend_data

        IMPORT_ROOT_ATTRIBUTES.each do |name|
          pool_attributes[name.underscore] = pool_json[name]
        end

        pool_attributes[:pool_type] = pool_json[:type]
        pool_attributes[:stacking_id] = pool_json[:stackId]

        combined_attributes = pool_json[:productAttributes] + pool_json[:attributes]
        combined_attributes.each do |attr|
          case attr[:name]
          when 'multi-entitlement'
            pool_attributes[:multi_entitlement] = attr[:value] == 'yes'
          when 'requires_host'
            pool_attributes[:hypervisor_id] = ::Katello::Host::SubscriptionFacet.find_by(uuid: attr[:value])&.host_id
          when 'unmapped_guests_only'
            pool_attributes[:unmapped_guest] = attr[:value] == 'true'
          when 'virt_only'
            pool_attributes[:virt_only] = attr[:value] == 'true'
          when 'virt_limit'
            pool_attributes[:virt_who] = attr[:value].to_i > 0
          else
            if IMPORT_ATTRIBUTES.include?(attr[:name])
              pool_attributes[attr[:name]] = attr[:value]
            end
          end
        end

        update!(pool_attributes)
        create_product_associations
      end

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
