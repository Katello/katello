module Katello
  module Candlepin
    class Consumer
      attr_accessor :uuid

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
        Resources::Candlepin::Consumer.checkin(self.uuid, checkin_time)
      end
    end
  end
end
