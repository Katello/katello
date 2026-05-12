module Katello
  module Resources
    module Candlepin
      class UpstreamEntitlement < UpstreamCandlepinResource
        class << self
          def path(id = nil)
            "#{self.prefix}/entitlements/#{id}"
          end

          def update(entitlement_id, quantity)
            issue_request(
              method: :put,
              path: path(entitlement_id),
              headers: default_headers,
              payload: {quantity: quantity}.to_json,
              process: false
            )
          end
        end
      end
    end
  end
end
