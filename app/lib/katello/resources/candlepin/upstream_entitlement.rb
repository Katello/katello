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
            conn = resource
            conn.put(path(entitlement_id)) do |req|
              req.headers.merge!(HttpResource.stringify_headers(self.default_headers))
              req.body = body
            end
          end
        end
      end
    end
  end
end
