module Katello
  module Resources
    module Candlepin
      class UpstreamPool < UpstreamCandlepinResource
        extend PoolResource

        class << self
          def get(params = [])
            conn = resource
            response = conn.get(path + query_string(params))
            raise Katello::Errors::UpstreamConsumerGone if response.status == 410
            response
          end

          def path(id = nil, owner_label = nil)
            super(id, owner_label || upstream_owner_id)
          end
        end
      end
    end
  end
end
