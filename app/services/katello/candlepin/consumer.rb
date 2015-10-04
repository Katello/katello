module Katello
  module Candlepin
    class Consumer
      include ::Katello::LazyAccessor

      ENTITLEMENTS_VALID = 'valid'
      ENTITLEMENTS_PARTIAL = 'partial'
      ENTITLEMENTS_INVALID = 'invalid'

      attr_accessor :uuid

      lazy_accessor :consumer_info, :initializer => :backend_data

      def initialize(uuid)
        self.uuid = uuid
      end

      def regenerate_identity_certificates
        Resources::Candlepin::Consumer.regenerate_identity_certificates(self.uuid)
      end

      def backend_data
        Resources::Candlepin::Consumer.get(self.uuid)
      end

      def checkin(checkin_time)
        Resources::Candlepin::Consumer.checkin(uuid, checkin_time)
      end

      def entitlement_status
        consumer_info[:entitlementStatus]
      end
    end
  end
end
