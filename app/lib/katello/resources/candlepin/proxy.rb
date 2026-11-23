module Katello
  module Resources
    module Candlepin
      class Proxy
        def self.logger
          ::Foreman::Logging.logger('katello/cp_proxy')
        end

        def self.post(path, body)
          logger.debug "Sending POST request to Candlepin: #{path}"
          CandlepinResource.post(path_with_cp_prefix(path), body,
            {:accept => :json, :content_type => :json}.merge(User.cp_oauth_header))
        end

        def self.delete(path, body = nil)
          logger.debug "Sending DELETE request to Candlepin: #{path}"
          headers = {:accept => :json, :content_type => :json}.merge(User.cp_oauth_header)
          if body
            CandlepinResource.delete(path_with_cp_prefix(path), body, headers)
          else
            CandlepinResource.delete(path_with_cp_prefix(path), headers)
          end
        end

        def self.get(path, extra_headers = {})
          logger.debug "Sending GET request to Candlepin: #{path}"
          CandlepinResource.get(path_with_cp_prefix(path),
            extra_headers.merge!(default_request_headers))
        rescue RestClient::NotModified => e
          e.response
        end

        def self.put(path, body)
          logger.debug "Sending PUT request to Candlepin: #{path}"
          CandlepinResource.put(path_with_cp_prefix(path), body,
            {:accept => :json, :content_type => :json}.merge(User.cp_oauth_header))
        end

        def self.path_with_cp_prefix(path)
          CandlepinResource.prefix + path
        end

        def self.default_request_headers
          @default_request_headers ||= User.cp_oauth_header.merge(accept: :json)
        end
      end
    end
  end
end
