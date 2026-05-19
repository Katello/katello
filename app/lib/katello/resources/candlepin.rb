module Katello
  module Resources
    module Candlepin
      TOTAL_COUNT_HEADER = 'x-total-count'.freeze

      class CandlepinResource < HttpResource
        include Katello::Concerns::OauthRequestSigning

        cfg = SETTINGS[:katello][:candlepin]
        url = cfg[:url]
        uri = URI.parse(url)
        self.prefix = uri.path
        self.site = "#{uri.scheme}://#{uri.host}:#{uri.port}"
        self.consumer_secret = cfg[:oauth_secret]
        self.consumer_key = cfg[:oauth_key]
        self.ssl_ca_file = ::Cert::Certs.backend_ca_cert_file(:candlepin)

        class << self
          def process_response(response)
            debug_level = (response.status >= 400) ? :error : :debug
            logger.send(debug_level, "Candlepin request #{response.headers['x-candlepin-request-uuid']} returned with code #{response.status}")
            super
          end

          def raise_faraday_exception(error, path, http_method)
            unless error.response && error.response[:headers]&.key?('x-version')
              fail ::Katello::Errors::CandlepinNotRunning
            end

            super
          end
        end

        def self.logger
          ::Foreman::Logging.logger('katello/cp_rest')
        end

        def self.default_headers(uuid = nil)
          # There are cases where virt-who needs to act on behalf of hypervisors it is managing.
          # If the uuid is specified, then that consumer is used in the headers rather than the
          # virt-who consumer uuid.
          # Current example is creating a hypervisor that in turn needs to get compliance.
          if !uuid.nil? && User.consumer?
            cp_oauth_header = { 'cp-consumer' => uuid }
          else
            cp_oauth_header = User.cp_oauth_header
          end

          headers = {'accept' => 'application/json',
                     'accept-language' => I18n.locale,
                     'content-type' => 'application/json'}

          request_id = ::Logging.mdc['request']
          headers['X-Correlation-ID'] = request_id if request_id

          headers.merge!(cp_oauth_header)
        end

        def self.name_to_key(a_name)
          a_name.tr(' ', '_')
        end

        def self.included_list(included)
          included.map { |value| "include=#{value}" }.join('&')
        end

        def self.build_path(base, params: {}, includes: [], page: nil, page_size: nil)
          parts = []
          query = hash_to_query(params)
          parts << included_list(includes) unless includes.empty?
          parts << "per_page=#{page_size}&page=#{page}" if page && page_size
          extra = parts.reject(&:blank?).join('&')
          return base + query if extra.empty?
          separator = query.empty? ? '?' : '&'
          base + query + separator + extra
        end

        def self.parse_json(response, array: false, default: nil)
          body = response&.body
          body = default if default && body.blank?
          parsed = JSON.parse(body)
          array ? ::Katello::Util::Data.array_with_indifferent_access(parsed) : parsed.with_indifferent_access
        end

        def self.update_content_overrides_for(resource_path, _id, content_overrides)
          return [] if content_overrides.empty?

          attrs_to_delete = []
          attrs_to_update = []
          content_overrides.each do |override|
            if override[:value]
              attrs_to_update << override
            else
              attrs_to_delete << override
            end
          end

          if attrs_to_update.present?
            result = Candlepin::CandlepinResource.put(join_path(resource_path, 'content_overrides'),
                                                      attrs_to_update.to_json, headers: default_headers)
          end
          if attrs_to_delete.present?
            result = Candlepin::CandlepinResource.issue_request(
              method: :delete,
              path: join_path(resource_path, 'content_overrides'),
              headers: default_headers,
              payload: attrs_to_delete.to_json
            )
          end
          parse_json(result, array: true, default: '[]')
        end

        def self.fetch_paged(page_size = -1)
          if page_size == -1
            page_size = SETTINGS[:katello][:candlepin][:bulk_load_size]
          end
          page = 0
          content = []
          loop do
            page += 1
            data = yield("per_page=#{page_size}&page=#{page}")
            content.concat(data)
            break if data.size < page_size
          end
          content
        end
      end

      class UpstreamCandlepinResource < CandlepinResource
        extend ::Katello::Util::HttpProxy

        self.prefix = '/subscription'

        class << self
          def sign_request(_req, _url, _method)
          end

          def default_headers(uuid = nil)
            super(uuid).except('cp-user', 'cp-consumer')
          end

          # Creates a new Faraday connection with client cert auth for upstream
          # Candlepin (Red Hat CDN). Use for calls with custom URL/certs (export,
          # update, regenerate). For default upstream calls, use faraday_connection
          # which memoizes the connection for reuse.
          def resource(url: self.site + self.path, client_cert: self.client_cert, client_key: self.client_key, ca_file: nil)
            timeout = Setting[:manifest_refresh_timeout]

            Faraday.new(url: url) do |f|
              f.options.open_timeout = timeout
              f.options.timeout = timeout
              f.headers = self.default_headers

              f.ssl.client_cert = OpenSSL::X509::Certificate.new(client_cert)
              f.ssl.client_key = OpenSSL::PKey::RSA.new(client_key)
              f.ssl.ca_file = ca_file if ca_file

              if proxy&.cacert.present?
                cert_store = OpenSSL::X509::Store.new
                Foreman::Util.add_ca_bundle_to_store(proxy.cacert, cert_store)
                f.ssl.cert_store = cert_store
              end

              f.ssl.verify = ca_file.present? || proxy&.cacert.present?

              f.proxy = self.proxy_uri if self.proxy_uri

              f.adapter :net_http_persistent
            end
          end

          def faraday_connection(_path = '')
            org_id = Organization.current&.id
            @faraday_connections ||= {}
            @faraday_connections[org_id] ||= resource(url: self.site + self.path, client_cert: client_cert, client_key: client_key, ca_file: nil)
          end

          def reset_connection!
            @faraday_connections = nil
            @upstream_owner_ids = nil
          end

          def client_cert
            upstream_id_cert['cert']
          end

          def client_key
            upstream_id_cert['key']
          end

          def upstream_api_uri
            URI.parse(upstream_consumer['apiUrl'])
          end

          def site
            default_port = (upstream_api_uri.scheme == 'https') ? 443 : 80
            site = "#{upstream_api_uri.scheme}://#{upstream_api_uri.host}"
            (upstream_api_uri.port == default_port) ? site : "#{site}:#{upstream_api_uri.port}"
          end

          def upstream_id_cert
            unless upstream_consumer && upstream_consumer['idCert'] && upstream_consumer['idCert']['cert'] && upstream_consumer['idCert']['key']
              Rails.logger.error "Upstream identity certificate not available"
              fail _("Upstream identity certificate not available")
            end
            upstream_consumer['idCert']
          end

          def upstream_owner_id
            org_id = Organization.current&.id
            @upstream_owner_ids ||= {}
            @upstream_owner_ids[org_id] ||= begin
              response = Katello::Resources::Candlepin::UpstreamConsumer.issue_request(
                method: :get,
                path: Katello::Resources::Candlepin::UpstreamConsumer.path,
                headers: default_headers
              )
              JSON.parse(response.body)['owner']['key']
            end
          end

          def upstream_consumer_id
            upstream_consumer['uuid']
          end

          def upstream_consumer
            fail _("Current organization not set.") unless Organization.current
            upstream_consumer = Organization.current.owner_details['upstreamConsumer']
            fail Katello::Errors::NoManifestImported unless upstream_consumer

            upstream_consumer
          end
        end # class << self
      end # UpstreamCandlepinResource

      module AdminResource
        def path
          "#{self.prefix}/admin"
        end
      end

      module ConsumerResource
        def path(id = nil)
          "#{self.prefix}/consumers/#{id}"
        end
      end

      module OwnerResource
        def path(id = nil)
          "#{self.prefix}/owners/#{id}"
        end
      end

      module PoolResource
        def path(id = nil, owner_label = nil)
          if owner_label && id
            "#{prefix}/owners/#{owner_label}/pools/#{id}"
          elsif owner_label
            "#{prefix}/owners/#{owner_label}/pools/"
          else
            "#{prefix}/pools/#{id}"
          end
        end
      end
    end
  end
end
