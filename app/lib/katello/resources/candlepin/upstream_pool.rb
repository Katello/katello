module Katello
  module Resources
    module Candlepin
      class UpstreamPool < UpstreamCandlepinResource
        extend PoolResource

        class << self
          def get(*args)
            conn = resource
            response = conn.get(path, *args)
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
