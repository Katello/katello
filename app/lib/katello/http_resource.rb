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
      [:get, :delete].each do |method|
        define_method(method) do |path, headers: nil, params: nil|
          issue_request(method: method, path: path, headers: headers, params: params)
        end
      end

      [:post, :put, :patch].each do |method|
        define_method(method) do |path, payload = nil, headers: nil, params: nil|
          issue_request(method: method, path: path, headers: headers, payload: payload, params: params)
        end
      end

      def logger
        fail NotImplementedError
      end

      def process_response(resp)
        logger.debug { "Processing response: #{resp.status}" }
        logger.debug { filter_sensitive_data(resp.body) }
        return resp unless resp.status >= 400
        parsed = {}
        message = "HTTP error while processing the call"
        service_code = ""
        status_code = resp.status.to_s
        begin
          parsed = JSON.parse resp.body
          message = parsed["displayMessage"] if parsed["displayMessage"]
          service_code = parsed["code"] if parsed["code"]
        rescue => error
          logger.error "Error parsing the body: " << error.backtrace.join("\n")
          logger.error "Remote server status code " << resp.status.to_s
          raise_http_error(message: resp.body.presence || error.to_s, status_code: status_code, response_body: resp.body, service_code: service_code)
        end
        raise_http_error(message: message, status_code: status_code, response_body: resp.body, service_code: service_code)
      end

      def stringify_headers(headers)
        (headers || {}).transform_keys(&:to_s).transform_values(&:to_s)
      end

      def issue_request(method:, path:, headers: {}, payload: nil, params: nil, process: true, connection: nil)
        path = "#{path}#{query_string(params)}" if params
        headers = stringify_headers(headers)
        conn = connection || faraday_connection
        full_url = connection ? "#{conn.url_prefix}#{path}" : self.site + path
        logger.debug { "Resource #{method.upcase} request: #{full_url}" }
        logger.debug { "Headers: #{headers.to_json}" }
        logger.debug { "Body: #{filter_sensitive_data(payload.to_json)}" } if payload
        response = conn.send(method, path) do |req|
          sign_request(req, full_url, method)
          req.headers.merge!(headers) if headers
          req.body = payload if payload
        end

        process ? process_response(response) : response
      rescue Faraday::ConnectionFailed
        service = path.split("/").second
        raise Errors::ConnectionRefusedException, _("A backend service [ %s ] is unreachable") % service.capitalize
      rescue Faraday::Error => e
        raise_faraday_exception e, path, method.upcase
      end

      def raise_faraday_exception(e, a_path, http_method)
        msg = "#{name}: #{e.message} (#{http_method} #{a_path})"
        status_code = e.response&.dig(:status)
        if status_code.present?
          raise_http_error(message: msg, status_code: status_code.to_s, response_body: e.response&.dig(:body))
        else
          raise_network_error(msg)
        end
      end

      def raise_http_error(message:, status_code:, response_body:, service_code: '')
        fail HttpError, {
          message: message,
          service_code: service_code,
          code: status_code,
          response_body: response_body,
        }
      end

      def raise_network_error(message)
        fail NetworkException, message
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

      def query_string(params)
        return '' if params.nil? || (params.respond_to?(:empty?) && params.empty?)
        "?#{URI.encode_www_form(params)}"
      end

      alias_method :hash_to_query, :query_string
    end
  end
end
