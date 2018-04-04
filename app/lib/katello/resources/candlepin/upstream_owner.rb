module Katello
  module Resources
    module Candlepin
      class UpstreamOwner < UpstreamCandlepinResource
        extend OwnerResource

        class << self
          def path(id = upstream_owner_id)
            super(id)
          end
        end
      end
    end
  end
end
