require 'net/http/persistent'
require 'ostruct'

module Katello
  module Resources
    module Candlepin
      # Provides persistent HTTP connection pooling for CandlepinResource.
      #
      # Net::HTTP::Persistent maintains one TCP+TLS connection per thread,
      # reused across all Candlepin calls within that thread. Stale connections
      # are detected and re-established automatically by the library.
      #
      # Include in CandlepinResource; set `self.use_persistent_connection = false`
      # in subclasses that connect to different servers (e.g. UpstreamCandlepinResource).
      module PersistentConnection
        extend ActiveSupport::Concern

        # Response wrapper that preserves the RestClient::Response contract.
        #
        # Inherits from String (like RestClient::Response) so that
        # MultiJson.load(exception.response) works in CandlepinError.from_exception.
        class PooledResponse < String
          attr_reader :code, :headers, :request

          def initialize(net_response, url:)
            super(net_response.body || '')
            @code = net_response.code.to_i
            @headers = {}
            net_response.each_header do |k, v|
              @headers[k.downcase.tr('-', '_').to_sym] = v
            end
            @request = OpenStruct.new(url: url)
          end

          def body
            to_s
          end
        end

        # Translate RestClient-style symbol values to proper MIME types.
        # RestClient converts {:accept => :json} to "Accept: application/json",
        # but Net::HTTP passes symbols literally ("Accept: json") which Candlepin rejects.
        CONTENT_TYPE_MAP = {json: 'application/json', xml: 'application/xml'}.freeze

        included do
          class_attribute :use_persistent_connection, default: true
        end

        class_methods do
          def persistent_http
            @persistent_http ||= begin
              http = Net::HTTP::Persistent.new(name: 'candlepin')
              http.idle_timeout = 30
              http.max_requests = 500
              http.ca_file = ssl_ca_file if ssl_ca_file
              http.open_timeout = SETTINGS[:katello][:rest_client_timeout]
              http.read_timeout = SETTINGS[:katello][:rest_client_timeout]
              http
            end
          end

          def issue_request(method:, path:, headers: {}, payload: nil)
            return super unless use_persistent_connection

            url = self.site + path
            uri = URI.parse(url)

            request = Katello::HttpResource::REQUEST_MAP[method].new(uri)

            # OAuth signing — same consumer/secret as rest_client(), applied to the actual request
            consumer = OAuth::Consumer.new(
              self.consumer_key, self.consumer_secret,
              site: self.site, http_method: method,
              request_token_path: '', authorize_path: '', access_token_path: ''
            )
            consumer.sign!(request)

            (headers || {}).each do |k, v|
              request[k.to_s] = CONTENT_TYPE_MAP[v] || v.to_s
            end

            if payload
              request.body = payload
              request.content_type = 'application/json' unless request['Content-Type']
            end

            logger.debug("Pooled Candlepin #{method.upcase} request: #{path}")
            begin
              logger.debug "Body: #{filter_sensitive_data(payload.to_json)}"
            rescue JSON::GeneratorError, Encoding::UndefinedConversionError
              logger.debug "Body: Error: could not render payload as json"
            end if payload

            net_response = persistent_http.request(uri, request)
            response = PooledResponse.new(net_response, url: url)

            if response.code >= 400
              raise_pooled_error(response, path, method)
            end

            process_response(response)
          rescue Errno::ECONNREFUSED
            service = path.split("/").second
            raise Errors::ConnectionRefusedException,
              _("A backend service [ %s ] is unreachable") % service.capitalize
          rescue Net::HTTP::Persistent::Error => e
            raise Errors::ConnectionRefusedException,
              _("A backend service [ Candlepin ] is unreachable: %s") % e.message
          end

          private

          def raise_pooled_error(response, path, method)
            unless response.headers[:x_version]
              fail ::Katello::Errors::CandlepinNotRunning
            end

            exception_class = RestClient::Exceptions::EXCEPTIONS_MAP.fetch(
              response.code, RestClient::ExceptionWithResponse
            )
            exception = exception_class.new(response, response.code)

            raise_rest_client_exception(exception, path, method.to_s.upcase)
          end
        end
      end
    end
  end
end
