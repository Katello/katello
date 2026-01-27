module Katello
  module Candlepin
    class Consumer
      include LazyAccessor

      SYSTEM = "system".freeze

      lazy_accessor :consumer_attributes, :initializer => lambda { |_s| Resources::Candlepin::Consumer.get(uuid) }
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
