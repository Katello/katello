module Katello
  module Candlepin
    class Consumer
      include LazyAccessor

      ENTITLEMENTS_VALID = 'valid'.freeze
      ENTITLEMENTS_PARTIAL = 'partial'.freeze
      ENTITLEMENTS_INVALID = 'invalid'.freeze

      SYSTEM = "system".freeze
      HYPERVISOR = "hypervisor".freeze
      CANDLEPIN = "candlepin".freeze
      CP_TYPES = [SYSTEM, HYPERVISOR, CANDLEPIN].freeze

      lazy_accessor :entitlements, :initializer => lambda { |_s| Resources::Candlepin::Consumer.entitlements(uuid) }
      lazy_accessor :events, :initializer => lambda { |_s| Resources::Candlepin::Consumer.events(uuid) }
      lazy_accessor :consumer_attributes, :initializer => lambda { |_s| Resources::Candlepin::Consumer.get(uuid) }
      lazy_accessor :installed_products, :initializer => lambda { |_s| consumer_attributes['installedProducts'] }
      lazy_accessor :available_pools, :initializer => lambda { |_s| Resources::Candlepin::Consumer.available_pools(owner_label, uuid, false) }
      lazy_accessor :all_available_pools, :initializer => lambda { |_s| Resources::Candlepin::Consumer.available_pools(owner_label, uuid, true) }
      lazy_accessor :content_overrides, :initializer => (lambda do |_s|
                                                           Resources::Candlepin::Consumer.content_overrides(uuid).map do |override|
                                                             ::Katello::ContentOverride.from_entitlement_hash(override)
                                                           end
                                                         end)

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

      def update(params)
        ::Katello::Resources::Candlepin::Consumer.update(uuid, params)
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

      def pool_ids
        entitlements.map { |ent| ent['pool']['id'].to_s }
      end

      def virtual_guests
        return [] if self.uuid.nil?
        guest_uuids = Resources::Candlepin::Consumer.virtual_guests(self.uuid).map { |guest| guest['uuid'] }
        ::Host.joins(:subscription_facet).where("#{Katello::Host::SubscriptionFacet.table_name}.uuid" => guest_uuids)
      end

      def virtual_host
        return nil if self.uuid.nil?
        if (virtual_host_info = Resources::Candlepin::Consumer.virtual_host(self.uuid))
          ::Host.joins(:subscription_facet).where("#{Katello::Host::SubscriptionFacet.table_name}.uuid" => virtual_host_info[:uuid]).first
        end
      end

      def products
        pool_ids = self.entitlements.map { |entitlement| entitlement['pool']['id'] }
        Katello::Product.joins(:subscriptions => :pools).where("#{Katello::Pool.table_name}.cp_id" => pool_ids).enabled.uniq
      end

      def all_products
        ::Katello::Host::SubscriptionFacet.find_by_uuid(self.uuid).host.organization.products.enabled.uniq
      end

      def available_product_content(content_access_mode_all = false, content_access_mode_env = false)
        if content_access_mode_env
          host = ::Katello::Host::ContentFacet.find_by_uuid(self.uuid)
          return [] unless host.lifecycle_environment_id && host.content_view_id
          version = ContentViewVersion.in_environment(host.lifecycle_environment_id).where(:content_view_id => host.content_view_id).first
          content_view_version_id = version.id
        end
        if content_access_mode_all
          content = all_products.flat_map do |product|
            product.available_content(content_view_version_id)
          end
        else
          content = products.flat_map do |product|
            product.available_content(content_view_version_id)
          end
        end
        content.uniq
      end

      def compliance_reasons
        Resources::Candlepin::Consumer.compliance(uuid)['reasons'].map do |reason|
          "#{reason['attributes']['name']}: #{reason['message']}"
        end
      end

      def self.orphaned_consumer_ids
        #returns consumer ids in candlepin with no matching katello entry
        orphaned_ids = []
        User.as_anonymous_admin do
          cp_consumers = Organization.all.collect { |org| ::Katello::Resources::Candlepin::Consumer.get('owner' => org.label) }
          cp_consumers.flatten!
          cp_consumers.reject! { |consumer| consumer['type']['label'] == 'uebercert' }
          cp_consumer_ids = cp_consumers.map { |consumer| consumer["uuid"] }
          katello_consumer_ids = ::Katello::Host::SubscriptionFacet.pluck(:uuid)
          orphaned_ids = cp_consumer_ids - katello_consumer_ids
        end
        orphaned_ids
      end

      def self.distribution_to_puppet_os(name)
        return ::Operatingsystem::REDHAT_ATOMIC_HOST_OS if name == ::Operatingsystem::REDHAT_ATOMIC_HOST_DISTRO_NAME

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
