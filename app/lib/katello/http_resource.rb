require 'cgi'
require 'faraday'
require 'faraday/net_http_persistent'

module Katello
  class HttpResource
    class NetworkException < StandardError
    end

    class HttpError < StandardError
      attr_reader :service_code, :code, :response_body

      def initialize(params)
        super params[:message]
        @service_code = params[:service_code]
        @code = params[:code]
        @response_body = params[:response_body]
      end
    end

    include Katello::Concerns::FilterSensitiveData

    class_attribute :consumer_secret, :consumer_key, :prefix, :site, :default_headers,
                    :ssl_client_cert, :ssl_client_key, :ssl_ca_file

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

    class << self
      [:get, :post, :put, :patch, :delete].each do |method|
        define_method(method) do |*args|
          issue_request(
            method: method,
            path: args.first,
            headers: args.length > 1 ? args.last : nil,
            payload: args.length > 2 ? args[1] : nil
          )
        end
      end

      def logger
        fail NotImplementedError
      end

      def process_response(resp)
        logger.debug "Processing response: #{resp.status}"
        logger.debug filter_sensitive_data(resp.body)
        return resp unless resp.status >= 400
        parsed = {}
        message = "Rest exception while processing the call"
        service_code = ""
        status_code = resp.status.to_s
        begin
          parsed = JSON.parse resp.body
          message = parsed["displayMessage"] if parsed["displayMessage"]
          service_code = parsed["code"] if parsed["code"]
        rescue => error
          logger.error "Error parsing the body: " << error.backtrace.join("\n")
          if %w(404 500 502 503 504).member? resp.status.to_s
            logger.error "Remote server status code " << resp.status.to_s
            raise HttpError, {:message => error.to_s, :service_code => service_code, :code => status_code, :response_body => resp.body}, caller
          else
            raise NetworkException, [resp.status.to_s, resp.body].reject { |s| s.blank? }.join(' ')
          end
        end
        fail HttpError, {:message => message, :service_code => service_code, :code => status_code, :response_body => resp.body}, caller
      end

      def stringify_headers(headers)
        (headers || {}).transform_keys(&:to_s).transform_values(&:to_s)
      end

      def issue_request(method:, path:, headers: {}, payload: nil)
        headers = stringify_headers(headers)
        logger.debug("Resource #{method.upcase} request: #{path}")
        logger.debug "Headers: #{headers.to_json}"
        begin
          logger.debug "Body: #{filter_sensitive_data(payload.to_json)}"
        rescue JSON::GeneratorError, Encoding::UndefinedConversionError
          logger.debug "Body: Error: could not render payload as json"
        end

        conn = faraday_connection
        response = conn.send(method, path) do |req|
          sign_request(req, self.site + path, method)
          req.headers.merge!(headers) if headers
          req.body = payload if payload
        end

        process_response(response)
      rescue Faraday::ConnectionFailed
        service = path.split("/").second
        raise Errors::ConnectionRefusedException, _("A backend service [ %s ] is unreachable") % service.capitalize
      rescue Faraday::Error => e
        raise_faraday_exception e, path, method.upcase
      end

      def raise_faraday_exception(e, a_path, http_method)
        msg = "#{name}: #{e.message} (#{http_method} #{a_path})"
        raise HttpError, { message: msg, service_code: '', code: e.response&.dig(:status).to_s, response_body: e.response&.dig(:body) }
      end

      def join_path(*args)
        args.inject("") do |so_far, current|
          so_far << '/' if (!so_far.empty? && so_far[so_far.length - 1].chr != '/') || current[0].chr != '/'
          so_far << current.strip
        end
      end

      def faraday_connection
        @faraday_connection ||= begin
          timeout = SETTINGS[:katello][:rest_client_timeout]
          Faraday.new(url: self.site) do |f|
            f.options.open_timeout = timeout
            f.options.timeout = timeout
            f.ssl.ca_file = self.ssl_ca_file if self.ssl_ca_file
            f.ssl.client_cert = self.ssl_client_cert if self.ssl_client_cert
            f.ssl.client_key = self.ssl_client_key if self.ssl_client_key
            f.adapter :net_http_persistent
          end
        end
      end

      def sign_request(_req, _url, _method)
      end

      def hash_to_query(query_parameters)
        "?#{URI.encode_www_form(query_parameters)}"
      end
    end
  end
end
