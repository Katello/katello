module Katello
  module Resources
    module Candlepin
      class Proxy
        def self.logger
          ::Foreman::Logging.logger('katello/cp_proxy')
        end

        def self.get(path, extra_headers = {})
          proxy_request(:get, path, headers: extra_headers)
        end

        def self.post(path, body)
          proxy_request(:post, path, body: body)
        end

        def self.put(path, body)
          proxy_request(:put, path, body: body)
        end

        def self.delete(path, body = nil)
          proxy_request(:delete, path, body: body)
        end

        def self.proxy_request(method, path, body: nil, headers: {})
          logger.debug "Sending #{method.upcase} request to Candlepin: #{path}"
          full_path = CandlepinResource.prefix + path
          headers = HttpResource.stringify_headers(
            CandlepinResource.default_headers.merge(headers)
          )

          CandlepinResource.faraday_connection.send(method, full_path) do |req|
            CandlepinResource.sign_request(req, CandlepinResource.site + full_path, method)
            req.headers.merge!(headers)
            req.body = body if body
          end
        end
      end
    end
  end
end
