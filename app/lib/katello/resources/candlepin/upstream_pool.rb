module Katello
  module Resources
    module Candlepin
      class UpstreamPool < UpstreamCandlepinResource
        extend PoolResource

        class << self
          def get(params = [])
            response = issue_request(
              method: :get,
              path: path,
              headers: default_headers,
              params: params,
              process: false
            )
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
