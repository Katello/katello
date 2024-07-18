module Katello
  module Resources
    module Candlepin
      class Pool < CandlepinResource
        extend PoolResource

        class << self
          def get_for_owner(owner_key, include_temporary_guests = false)
            url = "#{prefix}/owners/#{owner_key}/pools?add_future=true"
            url += "&attribute=unmapped_guests_only:!true" if include_temporary_guests
            pools_json = self.get(url, self.default_headers).body
            JSON.parse(pools_json)
          end

          def create(owner_key, attrs)
            self.post("/candlepin/owners/#{owner_key}/pools", attrs.to_json, self.default_headers).body
          end

          def find(pool_id)
            begin
              pool_json = self.get(path(pool_id), self.default_headers).body
            rescue RestClient::ResourceNotFound
              raise Katello::Errors::CandlepinPoolGone
            end

            JSON.parse(pool_json).with_indifferent_access
          end

          def destroy(id)
            fail ArgumentError, "pool id has to be specified" unless id
            self.delete(path(id), self.default_headers).code.to_i
          end

          def consumer_uuids(pool_id)
            entitlement_json = self.get("#{path(pool_id)}/entitlements/consumer_uuids", self.default_headers).body
            JSON.parse(entitlement_json)
          end
        end
      end
    end
  end
end
