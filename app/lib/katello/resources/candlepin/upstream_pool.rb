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
            if response.status.between?(200, 299)
              response
            elsif [401, 410].include?(response.status)
              fail Katello::Errors::UpstreamConsumerGone
            else
              process_response(response)
            end
          end

          def path(id = nil, owner_label = nil)
            super(id, owner_label || upstream_owner_id)
          end
        end
      end
    end
  end
end
