module Katello
  module Resources
    module Candlepin
      class Proxy
        class << self
          def get(path, extra_headers = {})
            issue_proxy(:get, path, headers: extra_headers)
          end

          def post(path, body)
            issue_proxy(:post, path, payload: body)
          end

          def put(path, body)
            issue_proxy(:put, path, payload: body)
          end

          def delete(path, body = nil)
            issue_proxy(:delete, path, payload: body)
          end

          private

          def issue_proxy(method, path, payload: nil, headers: {})
            CandlepinResource.issue_request(
              method: method,
              path: CandlepinResource.prefix + path,
              headers: CandlepinResource.default_headers.merge(headers),
              payload: payload,
              process: false
            )
          end
        end
      end
    end
  end
end
