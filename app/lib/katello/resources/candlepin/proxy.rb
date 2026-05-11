module Katello
  module Resources
    module Candlepin
      class Proxy
        def self.logger
          ::Foreman::Logging.logger('katello/cp_proxy')
        end

        def self.post(path, body)
          logger.debug "Sending POST request to Candlepin: #{path}"
          conn = CandlepinResource.faraday_connection
          full_path = path_with_cp_prefix(path)
          conn.post(full_path) do |req|
            CandlepinResource.sign_request(req, CandlepinResource.site + full_path, :post)
            req.headers.merge!(stringify_headers({'accept' => 'application/json', 'content-type' => 'application/json'}.merge(User.cp_oauth_header)))
            req.body = body
          end
        end

        def self.delete(path, body = nil)
          logger.debug "Sending DELETE request to Candlepin: #{path}"
          conn = CandlepinResource.faraday_connection
          full_path = path_with_cp_prefix(path)
          conn.delete(full_path) do |req|
            CandlepinResource.sign_request(req, CandlepinResource.site + full_path, :delete)
            req.headers.merge!(stringify_headers({'accept' => 'application/json', 'content-type' => 'application/json'}.merge(User.cp_oauth_header)))
            req.body = body unless body.nil?
          end
        end

        def self.get(path, extra_headers = {})
          logger.debug "Sending GET request to Candlepin: #{path}"
          conn = CandlepinResource.faraday_connection
          full_path = path_with_cp_prefix(path)
          conn.get(full_path) do |req|
            CandlepinResource.sign_request(req, CandlepinResource.site + full_path, :get)
            req.headers.merge!(stringify_headers(extra_headers.merge!(default_request_headers)))
          end
        end

        def self.put(path, body)
          logger.debug "Sending PUT request to Candlepin: #{path}"
          conn = CandlepinResource.faraday_connection
          full_path = path_with_cp_prefix(path)
          conn.put(full_path) do |req|
            CandlepinResource.sign_request(req, CandlepinResource.site + full_path, :put)
            req.headers.merge!(stringify_headers({'accept' => 'application/json', 'content-type' => 'application/json'}.merge(User.cp_oauth_header)))
            req.body = body
          end
        end

        def self.path_with_cp_prefix(path)
          CandlepinResource.prefix + path
        end

        def self.default_request_headers
          User.cp_oauth_header.merge('accept' => 'application/json')
        end

        def self.stringify_headers(headers)
          HttpResource.stringify_headers(headers)
        end
      end
    end
  end
end
