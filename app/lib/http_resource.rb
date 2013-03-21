#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'oauth'
require 'cgi'

class HttpResource

  class NetworkException < StandardError
  end

  class RestClientException < StandardError
    attr_reader :service_code, :code
    def initialize params
      super params[:message]
      @service_code = params[:service_code]
      @code = params[:code]
    end
  end

  class_attribute :consumer_secret, :consumer_key, :ca_cert_file, :prefix, :site, :default_headers

  attr_reader :json

  def initialize(json={})
    @json = json
  end

  def [](key)
    @json[key]
  end

  def []=(key, value)
    @json[key] = value
  end

  class << self
    # children must redefine
    def logger
      raise NotImplementedError
    end

    def process_response(resp)
      logger.debug "Processing response: #{resp.code}"
      logger.debug resp.body
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
        if ["404", "500", "502", "503", "504"].member? resp.code.to_s
          logger.error "Remote server status code " << resp.code.to_s
          raise RestClientException,{:message => error.to_s, :service_code => service_code, :code => status_code}, caller
        else
          raise NetworkException, [resp.code.to_s, resp.body].reject{|s| s.nil? or s.empty?}.join(' ')
        end
      end
      raise RestClientException,{:message => message, :service_code => service_code, :code => status_code}, caller
    end

    def print_debug_info(a_path, headers={}, payload={})
      logger.debug "Headers: #{headers.to_json}"
      # calling to_json on file has side-effects breaking manifest import.
      # this fix prevents this problem
      payload_to_print = payload.reduce({}) do |h, (k,v)|
        h[k] = case v
               when File then "{{file}}"
               else v
               end
      end
      logger.debug "Body: #{payload_to_print.to_json}"
    rescue => e
      logger.debug "Unable to print debug information"
    end

    def get(a_path, headers={})
      logger.debug "Resource GET request: #{a_path}"
      print_debug_info(a_path, headers)
      a_path = URI.encode(a_path)
      client = rest_client(Net::HTTP::Get, :get, a_path)
      result = process_response(client.get(headers))
      result
    rescue RestClient::Exception => e
      raise_rest_client_exception e, a_path, "GET"
    end

    def post(a_path, payload={}, headers={})
      logger.debug "Resource POST request: #{a_path}, #{payload}"
      print_debug_info(a_path, headers, payload)
      a_path = URI.encode(a_path)
      client = rest_client(Net::HTTP::Post, :post, a_path)
      result = process_response(client.post(payload, headers))
      result
    rescue RestClient::Exception => e
      raise_rest_client_exception e, a_path, "POST"
    end

    def put(a_path, payload={}, headers={})
      logger.debug "Resource PUT request: #{a_path}, #{payload}"
      print_debug_info(a_path, headers, payload)
      a_path = URI.encode(a_path)
      client = rest_client(Net::HTTP::Put, :put, a_path)
      result = process_response(client.put(payload, headers))
      result
    rescue RestClient::Exception => e
      raise_rest_client_exception e, a_path, "PUT"
    end

    def delete(a_path=nil, headers={})
      logger.debug "Resource DELETE request: #{a_path}"
      print_debug_info(a_path, headers)
      a_path = URI.encode(a_path)
      client = rest_client(Net::HTTP::Delete, :delete, a_path)
      result = process_response(client.delete(headers))
      result
    rescue RestClient::Exception => e
      raise_rest_client_exception e, a_path, "DELETE"
    end

    # re-raise the same exception with nicer error message
    def raise_rest_client_exception e, a_path, http_method
      # message method in rest-client is hardcoded - we need to override it
      msg = "#{name}: #{e.message} #{e.http_body} (#{http_method} #{a_path})"
      (class << e; self; end).instance_eval do
        define_method(:message) do
           msg
        end
      end
      raise e
    end

    def join_path(*args)
      args.inject("") do |so_far, current|
        so_far << '/' if (!so_far.empty? && so_far[so_far.length-1].chr != '/') || current[0].chr != '/'
        so_far << current.strip
      end
    end

    def create_thing(request_type)
      request_type.new()
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
      RestClient::Resource.new url, {
        :headers => added_header,
        :open_timeout => Katello.config.rest_client_timeout,
        :timeout => Katello.config.rest_client_timeout
      }
    end

    # Encode url element if its not nil. This helper method is used mainly in resource path methods.
    #
    # @param [String] element to encode
    # @return [String] encoded element or nil
    def url_encode(element)
      CGI::escape element.to_s unless element.nil?
    end

    def hash_to_query(query_parameters)
      query_parameters.inject("?") do |so_far, current|
        so_far << "&" unless so_far == "?"
        so_far << "#{current[0].to_s}=#{url_encode(current[1])}"
      end
    end

  end
end
