require 'oauth'
require 'cgi'

module Katello
  class HttpResource
    class NetworkException < StandardError
    end

    class RestClientException < StandardError
      attr_reader :service_code, :code
      def initialize(params)
        super params[:message]
        @service_code = params[:service_code]
        @code = params[:code]
      end
    end

    include Katello::Concerns::FilterSensitiveData

    class_attribute :consumer_secret, :consumer_key, :ca_cert_file, :prefix, :site, :default_headers,
                    :ssl_client_cert, :ssl_client_key

    attr_reader :json

    def initialize(json = {})
      @json = json
    end

    def [](key)
      @json[key]
    end

    def []=(key, value)
      @json[key] = value
    end

    REQUEST_MAP = {
      get: Net::HTTP::Get,
      post: Net::HTTP::Post,
      put: Net::HTTP::Put,
      patch: Net::HTTP::Patch,
      delete: Net::HTTP::Delete
    }.freeze

    class << self
      REQUEST_MAP.keys.each do |key|
        define_method(key) do |*args|
          issue_request(
            method: key,
            path: args.first,
            headers: args.length > 1 ? args.last : nil,
            payload: args.length > 2 ? args[1] : nil # non-GET method signatures use payload as the second argument, keeping headers as the last element
          )
        end
      end

      def logger
        fail NotImplementedError
      end

      def process_response(resp)
        logger.debug "Processing response: #{resp.code}"
        logger.debug filter_sensitive_data(resp.body)
        return resp unless resp.code.to_i >= 400
        parsed = {}
        message = "Rest exception while processing the call"
        service_code = ""
        status_code = resp.code.to_s
        begin
          parsed = JSON.parse resp.body
          message = parsed["displayMessage"] if parsed["displayMessage"]
          service_code = parsed["code"] if parsed["code"]
        rescue => error
          logger.error "Error parsing the body: " << error.backtrace.join("\n")
          if %w(404 500 502 503 504).member? resp.code.to_s
            logger.error "Remote server status code " << resp.code.to_s
            raise RestClientException, {:message => error.to_s, :service_code => service_code, :code => status_code}, caller
          else
            raise NetworkException, [resp.code.to_s, resp.body].reject { |s| s.blank? }.join(' ')
          end
        end
        fail RestClientException, {:message => message, :service_code => service_code, :code => status_code}, caller
      end

      def issue_request(method:, path:, headers: {}, payload: nil)
        logger.debug("Resource #{method.upcase} request: #{path}")
        logger.debug "Headers: #{headers.to_json}"
        begin
          logger.debug "Body: #{filter_sensitive_data(payload.to_json)}"
        rescue JSON::GeneratorError
          logger.debug "Body: Error: could not render payload as json"
        end

        client = rest_client(REQUEST_MAP[method], method, path)
        args = [method, payload, headers].compact

        process_response(client.send(*args))
      rescue RestClient::Exception => e
        raise_rest_client_exception e, path, method.upcase
      rescue Errno::ECONNREFUSED
        service = path.split("/").second
        raise Errors::ConnectionRefusedException, _("A backend service [ %s ] is unreachable") % service.capitalize
      end

      # re-raise the same exception with nicer error message
      def raise_rest_client_exception(e, a_path, http_method)
        msg = "#{name}: #{e.message} #{e.http_body} (#{http_method} #{a_path})"
        e.message = msg
        fail e
      end

      def join_path(*args)
        args.inject("") do |so_far, current|
          so_far << '/' if (!so_far.empty? && so_far[so_far.length - 1].chr != '/') || current[0].chr != '/'
          so_far << current.strip
        end
      end

      # Creates a RestClient::Resource class with a signed OAuth style
      # Authentication header added to the request headers.
      def rest_client(http_type, method, path)
        # Need full path to properly generate the signature
        url = self.site + path
        params = { :site => self.site,
                   :http_method => method,
                   :request_token_path => "",
                   :authorize_path => "",
                   :access_token_path => ""}

        params[:ca_file] = self.ca_cert_file unless self.ca_cert_file.nil?
        # New OAuth consumer to setup signing the request
        consumer = OAuth::Consumer.new(self.consumer_key,
                            self.consumer_secret,
                            params)

        # The type is passed in, GET/POST/PUT/DELETE
        request = http_type.new(url)

        # Sign the request with OAuth
        consumer.sign!(request)
        # Extract the header and add it to the RestClient
        added_header = {'Authorization' => request['Authorization']}

        options = {
          :headers => added_header,
          :open_timeout => SETTINGS[:katello][:rest_client_timeout],
          :timeout => SETTINGS[:katello][:rest_client_timeout]
        }
        options[:ssl_ca_file] = self.ca_cert_file unless self.ca_cert_file.nil?
        options[:ssl_client_cert] = self.ssl_client_cert unless self.ssl_client_cert.nil?
        options[:ssl_client_key] = self.ssl_client_key unless self.ssl_client_key.nil?

        RestClient::Resource.new(url, options)
      end

      def hash_to_query(query_parameters)
        "?#{URI.encode_www_form(query_parameters)}"
      end
    end
  end
end
