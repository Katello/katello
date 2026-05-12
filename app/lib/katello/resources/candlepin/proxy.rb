module Katello
  module Resources
    module Candlepin
      class Proxy
        class << self
          def get(path, extra_headers = {})
            CandlepinResource.issue_request(
              method: :get,
              path: CandlepinResource.prefix + path,
              headers: CandlepinResource.default_headers.merge(extra_headers),
              process: false
            )
          end

          def post(path, body)
            CandlepinResource.issue_request(
              method: :post,
              path: CandlepinResource.prefix + path,
              headers: CandlepinResource.default_headers,
              payload: body,
              process: false
            )
          end

          def put(path, body)
            CandlepinResource.issue_request(
              method: :put,
              path: CandlepinResource.prefix + path,
              headers: CandlepinResource.default_headers,
              payload: body,
              process: false
            )
          end

          def delete(path, body = nil)
            CandlepinResource.issue_request(
              method: :delete,
              path: CandlepinResource.prefix + path,
              headers: CandlepinResource.default_headers,
              payload: body,
              process: false
            )
          end
        end
      end
    end
  end
end
