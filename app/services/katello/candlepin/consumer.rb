module Katello
  module Candlepin
    class Consumer
      include LazyAccessor

      ENTITLEMENTS_VALID = 'valid'
      ENTITLEMENTS_PARTIAL = 'partial'
      ENTITLEMENTS_INVALID = 'invalid'

      lazy_accessor :entitlements, :initializer => lambda { |_s| Resources::Candlepin::Consumer.entitlements(uuid) }
      lazy_accessor :events, :initializer => lambda { |_s| Resources::Candlepin::Consumer.events(uuid) }
      lazy_accessor :consumer_attributes, :initializer => lambda { |_s| Resources::Candlepin::Consumer.get(uuid) }
      lazy_accessor :installed_products, :initializer => lambda { |_s| consumer_attributes['installedProducts'] }
      lazy_accessor :available_pools, :initializer => lambda { |_s| Resources::Candlepin::Consumer.available_pools(uuid, false) }
      lazy_accessor :all_available_pools, :initializer => lambda { |_s| Resources::Candlepin::Consumer.available_pools(uuid, true) }

      attr_accessor :uuid

      def initialize(uuid)
        self.uuid = uuid
      end

      def regenerate_identity_certificates
        Resources::Candlepin::Consumer.regenerate_identity_certificates(self.uuid)
      end

      def checkin(checkin_time)
        Resources::Candlepin::Consumer.checkin(uuid, checkin_time)
      end

      def entitlement_status
        consumer_attributes[:entitlementStatus]
      end

      def filtered_pools(match_attached, match_host, match_installed, no_overlap)
        if match_host
          pools = self.available_pools
        elsif match_attached
          pools = self.entitlements.map { |ent| ent['pool'] }
        else
          pools = self.all_available_pools
        end

        # Only available pool's with a product on the system'
        if match_installed
          pools = pools.select do |pool|
            self.installed_products.any? do |installed_product|
              pool['providedProducts'].any? do |provided_product|
                installed_product['productId'] == provided_product['productId']
              end
            end
          end
        end

        # None of the available pool's products overlap a consumed pool's products
        if no_overlap
          pools = pools.select do |pool|
            pool['providedProducts'].all? do |provided_product|
              self.entitlements.all? do |consumed_entitlement|
                consumed_entitlement.providedProducts.all? do |consumed_product|
                  consumed_product.cp_id != provided_product['productId']
                end
              end
            end
          end
        end

        ::Katello::Pool.where(:cp_id => pools.map { |pool| pool['id'] })
      end

      def filter_entitlements(pool_id = nil, quantities = nil)
        filtered = entitlements
        filtered = filtered.select { |ent| ent['pool']['id'].to_s == pool_id.to_s } if pool_id

        if quantities && quantities.any?
          quantities.map!(&:to_s)
          filtered = quantities.map do |quantity|
            index = filtered.index { |ent| ent['quantity'].to_s == quantity }
            filtered.delete_at(index) if index
          end
          filtered.compact!
        end

        filtered
      end

      def virtual_guests
        guest_uuids = Resources::Candlepin::Consumer.virtual_guests(self.uuid).map { |guest| guest['uuid'] }
        ::Host.joins(:subscription_facet).where("#{Katello::Host::SubscriptionFacet.table_name}.uuid" => guest_uuids)
      end

      def virtual_host
        if virtual_host_info = Resources::Candlepin::Consumer.virtual_host(self.uuid)
          Katello::Host::SubscriptionFacet.find_by_uuid(virtual_host_info[:uuid])
        end
      end

      def compliance_reasons
        Resources::Candlepin::Consumer.compliance(uuid)['reasons'].map do |reason|
          "#{reason['attributes']['name']}: #{reason['message']}"
        end
      end

      def self.distribution_to_puppet_os(name)
        name = name.downcase
        if name =~ /red\s*hat/
          'RedHat'
        elsif name =~ /centos/
          'CentOS'
        elsif name =~ /fedora/
          'Fedora'
        end
      end
    end
  end
end
