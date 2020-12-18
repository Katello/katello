module Katello
  module Resources
    module Candlepin
      class Entitlement < CandlepinResource
        class << self
          def regenerate_entitlement_certificates_for_product(product_id)
            self.put("/candlepin/entitlements/product/#{product_id}", nil, self.default_headers).code.to_i
          end

          def regenerate_entitlement_certificates_for_consumer(uuid, lazy_regen = true)
            self.put("/candlepin/consumers/#{uuid}/certificates?lazy_regen=#{lazy_regen}", nil, self.default_headers).code.to_i
          end

          def get(id = nil, params = '')
            json = Candlepin::CandlepinResource.get(path(id) + params, self.default_headers).body
            JSON.parse(json)
          end

          def path(id = nil)
            "/candlepin/entitlements/#{id}"
          end
        end
      end
    end
  end
end
