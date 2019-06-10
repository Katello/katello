module Katello
  module Resources
    module Candlepin
      class UpstreamPool < UpstreamCandlepinResource
        extend PoolResource

        class << self
          def get(*args)
            resource.get(*args)
          rescue RestClient::Gone
            raise Katello::Errors::UpstreamConsumerGone
          end

          def path(id = nil, owner_label = nil)
            super(id, owner_label || upstream_owner_id)
          end
        end
      end
    end
  end
end
