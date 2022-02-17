module Katello
  module Resources
    module CDN
      SUPPORTED_SSL_VERSIONS = ['SSLv23', 'TLSv1'].freeze

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
        CDN_DOCKER_CONTAINER_LISTING = "CONTAINER_REGISTRY_LISTING".freeze

        def substitutor
          @substitutor ||= Util::CdnVarSubstitutor.new(self)
        end

        def initialize(url, options = {})
          @ssl_version = Setting[:cdn_ssl_version]
          if @ssl_version && !SUPPORTED_SSL_VERSIONS.include?(@ssl_version)
            fail("Invalid SSL version specified. Check the 'CDN SSL Version' setting")
          end

          options.reverse_merge!(:verify_ssl => 9)
          options.assert_valid_keys(:ssl_client_key,
                                    :ssl_client_cert,
                                    :ssl_ca_file,
                                    :ssl_ca_cert,
                                    :verify_ssl,
                                    :username,
                                    :password,
                                    :organization_label,
                                    :ssl_ca_cert)

          if options[:ssl_ca_cert].present?
            begin
              ca_cert = OpenSSL::X509::Certificate.new(options[:ssl_ca_cert])
            rescue
              raise _("Invalid SSL CA certificate given for CDN")
            end

            @cert_store = OpenSSL::X509::Store.new
            @cert_store.add_cert(ca_cert)
          end

          @url = url
          @uri = URI.parse(url)
          @options = options
        end

        def self.create(product: nil, cdn_configuration:)
          options = {}
          if cdn_configuration.redhat?
            options[:ssl_client_cert] = OpenSSL::X509::Certificate.new(product.certificate)
            options[:ssl_client_key] = OpenSSL::PKey::RSA.new(product.key)
            options[:ssl_ca_file] = self.ca_file
            self.new(cdn_configuration.url, options)
          else
            options[:username] = cdn_configuration.username
            options[:password] = cdn_configuration.password
            options[:organization_label] = cdn_configuration.upstream_organization_label
            options[:ssl_ca_cert] = cdn_configuration.ssl_ca
            CDN::KatelloCdn.new(cdn_configuration.url, options)
          end
        end

        def self.redhat_cdn_url
          SETTINGS[:katello][:redhat_repository_url]
        end

        def self.redhat_cdn?(url)
          url.include?(redhat_cdn_url)
        end

        def proxy
          ::HttpProxy.default_global_content_proxy
        end

        def http_downloader
          net = net_http_class.new(@uri.host, @uri.port)
          net.use_ssl = @uri.is_a?(URI::HTTPS)

          if @uri.is_a?(URI::HTTPS)
            net.cert = @options[:ssl_client_cert]
            net.key = @options[:ssl_client_key]
            net.ca_file = @options[:ssl_ca_file]
            net.cert_store = @cert_store
          end

          # NOTE: This was added because some proxies dont support SSLv23 and do not handle TLS 1.2
          # Valid values in ruby 1.9.3 are 'SSLv23' or 'TLSV1'
          # Run the following command in rails console to figure out other
          # valid constants in other ruby versions
          # "OpenSSL::SSL::SSLContext::METHODS"
          net.ssl_version = @ssl_version

          if (@options[:verify_ssl] == false) || (@options[:verify_ssl] == OpenSSL::SSL::VERIFY_NONE)
            net.verify_mode = OpenSSL::SSL::VERIFY_NONE
          elsif @options[:verify_ssl].is_a? Integer
            net.verify_mode = @options[:verify_ssl]
            net.verify_callback = lambda do |preverify_ok, ssl_context|
              if !preverify_ok || ssl_context.error != 0
                err_msg = "SSL Verification failed -- Preverify: #{preverify_ok}, Error: #{ssl_context.error_string} (#{ssl_context.error})"
                fail RestClient::SSLCertificateNotVerified, err_msg
              end
              true
            end
          end
          net
        end

        # rubocop:disable Metrics/MethodLength
        def get(path, _headers = {})
          net = http_downloader
          path = File.join(@uri.request_uri, path)
          used_url = File.join("#{@uri.scheme}://#{@uri.host}:#{@uri.port}", path)
          Rails.logger.info "CDN: Requesting path #{used_url}"
          req = Net::HTTP::Get.new(path)

          if @options[:username] && @options[:password]
            req.basic_auth(@options[:username], @options[:password])
          end

          begin
            net.start do |http|
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
          rescue SocketError
            raise _("Couldn't establish a connection to %s") % @uri
          rescue EOFError
            raise RestClient::ServerBrokeConnection
          rescue Timeout::Error
            raise RestClient::RequestTimeout
          rescue RestClient::ResourceNotFound
            raise Errors::NotFound, _("CDN loading error: %s not found") % used_url
          rescue RestClient::Unauthorized
            raise Errors::SecurityViolation, _("CDN loading error: access denied to %s") % used_url
          rescue RestClient::Forbidden
            raise Errors::SecurityViolation, _("CDN loading error: access forbidden to %s") % used_url
          end
        end
        # rubocop:enable Metrics/MethodLength

        def valid_path?(path, postfix)
          get(File.join(path, postfix)).present?
        rescue RestClient::MovedPermanently
          return true
        rescue Errors::NotFound
          return false
        end

        def fetch_substitutions(base_path)
          get(File.join(base_path, "listing")).split("\n")
        rescue Errors::NotFound => e # some of listing file points to not existing content
          log :error, e.message
          [] # return no substitution for unreachable listings
        end

        def self.ca_file
          "#{Katello::Engine.root}/ca/redhat-uep.pem"
        end

        def net_http_class
          if proxy
            uri = URI(proxy.url) #Net::HTTP::Proxy ignores port as part of the url
            Net::HTTP::Proxy("#{uri.host}", uri.port, proxy.username, proxy.password)
          else
            Net::HTTP
          end
        end

        def parse_host(host_or_url)
          uri = URI.parse(host_or_url)
          return uri.host || uri.path
        end

        def get_container_listings(content_path)
          JSON.parse(get(File.join(content_path, CdnResource::CDN_DOCKER_CONTAINER_LISTING)))
        end

        # eg content url listing file ->
        # /content/dist/rhel/server/7/7Server/x86_64/containers/CONTAINER_REGISTRY_LISTING
        # format
        #   {
        #   "header": {
        #       "version": "1.0"
        #   },
        #   "payload": {
        #       "registries": [
        #           { "name": "rhel",
        #             "url": "<docker pull url>",
        #             },
        #           { "name": "rhel7",
        #             "url": "test.com:5000/rhel"
        #             "aliases": [ "redhat/rhel7" ]
        #             }
        #       ]
        #   }
        # }
        def get_docker_registries(content_path)
          docker_listing = get_container_listings(content_path)
          docker_listing.try(:[], "payload").try(:[], "registries") || []
        rescue ::Katello::Errors::NotFound => e # some of listing file points to not existing content
          # If the container listing file was not found
          # there is probably no content to be had.
          Rails.logger.warn("Could not get to #{content_path}.")
          Rails.logger.warn e.to_s
          []
        end

        def log(level, *args)
          [Rails.logger, @logger].compact.each { |logger| logger.send(level, *args) }
        end
      end
    end
  end
end
