#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module Resources

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
      attr_reader :url, :product
      attr_accessor :proxy_host, :proxy_port, :proxy_user, :proxy_password

      def substitutor(logger = nil)
        @logger = logger
        Util::CdnVarSubstitutor.new(self)
      end

      def initialize(url, options = {})
        options.reverse_merge!(:verify_ssl => 9)
        options.assert_valid_keys(:ssl_client_key, :ssl_client_cert, :ssl_ca_file, :verify_ssl,
                                  :product)
        if options[:ssl_client_cert]
          options.reverse_merge!(:ssl_ca_file => CdnResource.ca_file)
        end
        load_proxy_settings
        @product = options[:product]

        @url = url
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

      def get(path, headers = {})
        path = File.join(@uri.request_uri, path)
        used_url = File.join("#{@uri.scheme}://#{@uri.host}:#{@uri.port}", path)
        Rails.logger.debug "CDN: Requesting path #{used_url}"
        req = Net::HTTP::Get.new(path)
        begin
          @net.start do |http|
            res = http.request(req, nil) { |http_response| http_response.read_body }
            code = res.code.to_i
            if code == 200
              return res.body
            else
              # we don't really use RestClient here (it doesn't allow to safely
              # set the proxy only for a set of requests and we don't want the
              # backend engines communication to go through the same proxy like
              # accessing CDN - its another use case)
              # But RestClient exceptions are really nice and can be handled in
              # the same way
              exception_class = RestClient::Exceptions::EXCEPTIONS_MAP[code] || RestClient::RequestFailed
              fail exception_class.new(nil, code)
            end
          end
        rescue EOFError
          raise RestClient::ServerBrokeConnection
        rescue Timeout::Error
          raise RestClient::RequestTimeout
        rescue RestClient::ResourceNotFound
          raise Errors::NotFound.new(_("CDN loading error: %s not found") % used_url)
        rescue RestClient::Unauthorized
          raise Errors::SecurityViolation.new(_("CDN loading error: access denied to %s") % used_url)
        rescue RestClient::Forbidden
          raise Errors::SecurityViolation.new(_("CDN loading error: access forbidden to %s") % used_url)
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
        if Katello.config.cdn_proxy && Katello.config.cdn_proxy.host
          self.proxy_host = parse_host(Katello.config.cdn_proxy.host)
          self.proxy_port = Katello.config.cdn_proxy.port
          self.proxy_user = Katello.config.cdn_proxy.user
          self.proxy_password = Katello.config.cdn_proxy.password
        end
      rescue URI::Error => e
        Rails.logger.error "Could not parse cdn_proxy:"
        Rails.logger.error e.to_s
      end

      def parse_host(host_or_url)
        uri = URI.parse(host_or_url)
        return uri.host || uri.path
      end

      def log(level, *args)
        [Rails.logger, @logger].compact.each { |logger| logger.send(level, *args)}
      end

    end
  end
end
