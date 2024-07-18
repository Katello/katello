module Katello
  module Candlepin
    class Consumer
      include LazyAccessor

      ENTITLEMENTS_VALID = 'valid'.freeze
      ENTITLEMENTS_PARTIAL = 'partial'.freeze
      ENTITLEMENTS_INVALID = 'invalid'.freeze
      ENTITLEMENTS_DISABLED = 'disabled'.freeze

      SYSTEM = "system".freeze
      HYPERVISOR = "hypervisor".freeze
      CANDLEPIN = "candlepin".freeze
      CP_TYPES = [SYSTEM, HYPERVISOR, CANDLEPIN].freeze

      lazy_accessor :entitlements, :initializer => lambda { |_s| Resources::Candlepin::Consumer.entitlements(uuid) }
      lazy_accessor :consumer_attributes, :initializer => lambda { |_s| Resources::Candlepin::Consumer.get(uuid) }
      lazy_accessor :installed_products, :initializer => lambda { |_s| consumer_attributes['installedProducts'] }
      lazy_accessor :available_pools, :initializer => lambda { |_s| Resources::Candlepin::Consumer.available_pools(owner_label, uuid, listall: false) }
      lazy_accessor :all_available_pools, :initializer => lambda { |_s| Resources::Candlepin::Consumer.available_pools(owner_label, uuid, listall: true) }
      lazy_accessor :content_overrides, :initializer => (lambda do |_s|
                                                           Resources::Candlepin::Consumer.content_overrides(uuid).map do |override|
                                                             ::Katello::ContentOverride.from_entitlement_hash(override)
                                                           end
                                                         end)
      lazy_accessor :purpose_compliance, :initializer => lambda { |_s| Resources::Candlepin::Consumer.purpose_compliance(uuid) }

      attr_accessor :uuid, :owner_label

      def initialize(uuid, owner_label)
        self.uuid = uuid
        self.owner_label = owner_label
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
                consumed_entitlement['pool']['providedProducts'].all? do |consumed_product|
                  consumed_product['cp_id'] != provided_product['productId']
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

        if quantities&.any?
          quantities.map!(&:to_s)
          filtered = quantities.map do |quantity|
            index = filtered.index { |ent| ent['quantity'].to_s == quantity }
            filtered.delete_at(index) if index
          end
          filtered.compact!
        end

        filtered
      end

      def pool_ids
        entitlements.map { |ent| ent['pool']['id'].to_s }
      end

      def virtual_guests
        return @virtual_guests unless @virtual_guests.nil?
        return [] if self.uuid.nil?
        guest_uuids = Resources::Candlepin::Consumer.virtual_guests(self.uuid).map { |guest| guest['uuid'] }
        @virtual_guests = ::Host.joins(:subscription_facet).where("#{Katello::Host::SubscriptionFacet.table_name}.uuid" => guest_uuids)
      end

      def virtual_host
        return nil if self.uuid.nil?
        if (virtual_host_info = Resources::Candlepin::Consumer.virtual_host(self.uuid))
          ::Host.joins(:subscription_facet).where("#{Katello::Host::SubscriptionFacet.table_name}.uuid" => virtual_host_info[:uuid]).first
        end
      end

      def compliance_reasons
        self.class.friendly_compliance_reasons(Resources::Candlepin::Consumer.compliance(uuid)['reasons'])
      end

      def entitlements?
        # use cahced consumer_attributes if possible
        count = @consumer_attributes.try(:[], 'entitlementCount')
        return count > 0 if count

        !entitlements.empty?
      end

      def self.friendly_compliance_reasons(candlepin_reasons)
        candlepin_reasons.map do |reason|
          product_name = reason['productName'] || reason['attributes']['name']
          "#{product_name}: #{reason['message']}"
        end
      end

      def self.distribution_to_puppet_os(name)
        return ::Operatingsystem::REDHAT_ATOMIC_HOST_OS if name == ::Operatingsystem::REDHAT_ATOMIC_HOST_DISTRO_NAME

        case name.downcase
        when /red\s*hat/
          'RedHat'
        when /centos/
          'CentOS'
        when /fedora/
          'Fedora'
        when /sles/, /suse.*enterprise.*/
          'SLES'
        when /debian/
          'Debian'
        when /ubuntu/
          'Ubuntu'
        when /oracle/
          'OracleLinux'
        when /almalinux/
          'AlmaLinux'
        when /rocky/
          'Rocky'
        when /amazon/
          'Amazon'
        else
          'Unknown'
        end
      end
    end
  end
end
