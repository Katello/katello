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

require 'rest_client'
require 'http_resource'

module CDN

  class Utils

    # takes releasever from contentUrl (e.g. 6Server, 6.0, 6.1)
    # returns hash e.g. {:major => 6, :minor => "6.1"}
    # used to be able to make hierarchial view for RH repos
    def self.parse_version(releasever)
      if releasever.to_s =~ /^\d/
        {:major => releasever[/^\d+/].to_i, :minor => releasever }
      else
        {}
      end
    end
  end

  class CdnResource
    attr_reader :url
    attr_accessor :proxy_host, :proxy_port, :proxy_user, :proxy_password

    def initialize url, options = {}
      options.reverse_merge!(:verify_ssl => 9)
      options.assert_valid_keys(:ssl_client_key, :ssl_client_cert, :ssl_ca_file, :verify_ssl)
      if options[:ssl_client_cert]
        options.reverse_merge!(:ssl_ca_file => CdnResource.ca_file)
      end
      load_proxy_settings

      @uri = URI.parse(url)
      @net = net_http_class.new(@uri.host, @uri.port)
      @net.use_ssl = @uri.is_a?(URI::HTTPS)

      @net.cert = options[:ssl_client_cert]
      @net.key = options[:ssl_client_key]
      @net.ca_file = options[:ssl_ca_file]

      if (options[:verify_ssl] == false) || (options[:verify_ssl] == OpenSSL::SSL::VERIFY_NONE)
        @net.verify_mode = OpenSSL::SSL::VERIFY_NONE
      elsif options[:verify_ssl].is_a? Integer
        @net.verify_mode = options[:verify_ssl]
        @net.verify_callback = lambda do |preverify_ok, ssl_context|
          if (!preverify_ok) || ssl_context.error != 0
            err_msg = "SSL Verification failed -- Preverify: #{preverify_ok}, Error: #{ssl_context.error_string} (#{ssl_context.error})"
            raise RestClient::SSLCertificateNotVerified.new(err_msg)
          end
          true
        end
      end
    end

    def get(path, headers={})
      path = File.join(@uri.request_uri,path)
      Rails.logger.debug "CDN: Requesting path #{path}"
      req = Net::HTTP::Get.new(path)
      begin
        @net.start do |http|
          res = http.request(req, nil) { |http_response| http_response.read_body }
          return res.body
        end
      rescue EOFError
        raise RestClient::ServerBrokeConnection
      rescue Timeout::Error
        raise RestClient::RequestTimeout
      end
    end

    def self.ca_file
      "#{Rails.root}/ca/redhat-uep.pem"
    end

    def net_http_class
      if proxy_host
        Net::HTTP::Proxy(proxy_host, proxy_port, proxy_user, proxy_password)
      else
        Net::HTTP
      end
    end

    def load_proxy_settings
      if AppConfig.cdn_proxy
        self.proxy_host = parse_host(AppConfig.cdn_proxy.host)
        self.proxy_port = AppConfig.cdn_proxy.port
        self.proxy_user = AppConfig.cdn_proxy.user
        self.proxy_password = AppConfig.cdn_proxy.password
      end
    end

    def parse_host(host_or_url)
      uri = URI.parse(host_or_url)
      return uri.host || uri.path
    end

 end

  class CdnVarSubstitutor
    def initialize url, options
      @url = url
      @options = options
      @resource = CdnResource.new(@url, @options)
    end

  # takes path e.g. "/rhel/server/5/$releasever/$basearch/os"
  # returns hash substituting variables:
  #
  #   { {"releasever" => "6Server", "basearch" => "i386"} =>  "/rhel/server/5/6Server/i386/os",
  #     {"releasever" => "6Server", "basearch" => "x86_64"} =>  "/rhel/server/5/6Server/x84_64/os"}
  #
  # values are loaded from CDN
    def substitute_vars(path_with_vars)
      paths_with_vars    = { {} => path_with_vars}
      paths_without_vars = {}

      while not paths_with_vars.empty?
        substitutions, path = paths_with_vars.shift

        if is_substituable path
          for_each_substitute_of_next_var substitutions, path do |new_substitution, new_path|
            paths_with_vars[new_substitution] = new_path
          end
        else
          paths_without_vars[substitutions] = path
        end
      end

      return paths_without_vars
    end

    def is_substituable path
      path.include?("$")
    end

    def is_substitute_of(substituted_url, original_url)
      substitutions = self.substitute_vars(original_url).values
      substitutions.include? substituted_url
    end

    protected

    def for_each_substitute_of_next_var(substitutions, path)
      if path =~ /^(.*?)\$([^\/]*)/
        base_path, var = $1, $2
        get_substitutions_from(base_path).each do |value|

          new_substitutions = substitutions.merge(var => value)
          new_path = path.sub("$#{var}",value)

          yield new_substitutions, new_path
        end
      end
    end

    def get_substitutions_from(base_path)
      @resource.get(File.join(base_path,"listing")).split("\n")
    end

  end
end
