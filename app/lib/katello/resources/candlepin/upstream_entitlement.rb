module Katello
  module Resources
    module Candlepin
      class UpstreamEntitlement < UpstreamCandlepinResource
        class << self
          def path(id = nil)
            "#{self.prefix}/entitlements/#{id}"
          end

          def update(entitlement_id, quantity)
            body = {quantity: quantity}.to_json

            self[entitlement_id].put(body)
          end
        end
      end
    end
  end
end
