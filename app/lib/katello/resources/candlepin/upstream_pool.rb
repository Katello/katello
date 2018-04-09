module Katello
  module Resources
    module Candlepin
      class UpstreamPool < UpstreamCandlepinResource
        extend PoolResource

        class << self
          def path(id = nil, owner_label = nil)
            super(id, owner_label || upstream_owner_id)
          end

          delegate :get, to: :resource
        end
      end
    end
  end
end
