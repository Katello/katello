module Katello
  module Resources
    module Candlepin
      module PoolResource
        def path(id = nil, owner_label = nil)
          if owner_label && id
            "#{prefix}/owners/#{owner_label}/pools/#{id}"
          elsif owner_label
            "#{prefix}/owners/#{owner_label}/pools/"
          else
            "#{prefix}/pools/#{id}"
          end
        end
      end

      class Pool < CandlepinResource
        extend PoolResource

        class << self
          def get_for_owner(owner_key, include_temporary_guests = false)
            url = "#{prefix}/owners/#{owner_key}/pools?add_future=true"
            url += "&attribute=unmapped_guests_only:!true" if include_temporary_guests
            pools_json = self.get(url, self.default_headers).body
            JSON.parse(pools_json)
          end

          def find(pool_id)
            pool_json = self.get(path(pool_id), self.default_headers).body
            fail ArgumentError, "pool id cannot contain ?" if pool_id["?"]
            JSON.parse(pool_json).with_indifferent_access
          end

          def destroy(id)
            fail ArgumentError, "pool id has to be specified" unless id
            self.delete(path(id), self.default_headers).code.to_i
          end

          def entitlements(pool_id, included = [])
            entitlement_json = self.get("#{path(pool_id)}/entitlements?#{included_list(included)}", self.default_headers).body
            JSON.parse(entitlement_json)
          end
        end
      end

      class UpstreamPool < UpstreamCandlepinResource
        extend PoolResource

        class << self
          def path(id = nil, owner_label = nil)
            super(id, owner_label || upstream_owner_id)
          end

          delegate :[], to: :resource
          delegate :get, to: :resource
        end
      end
    end # Candlepin
  end # Resources
end # Katello
