module Katello
  module Resources
    module Candlepin
      TOTAL_COUNT_HEADER = :x_total_count # as parsed by rest_client

      class CandlepinResource < HttpResource
        cfg = SETTINGS[:katello][:candlepin]
        url = cfg[:url]
        uri = URI.parse(url)
        self.prefix = uri.path
        self.site = "#{uri.scheme}://#{uri.host}:#{uri.port}"
        self.consumer_secret = cfg[:oauth_secret]
        self.consumer_key = cfg[:oauth_key]
        self.ca_cert_file = cfg[:ca_cert_file]

        class << self
          def process_response(response)
            debug_level = response.code >= 400 ? :error : :debug
            logger.send(debug_level, "Candlepin request #{response.headers[:x_candlepin_request_uuid]} returned with code #{response.code}")
            super
          end

          def raise_rest_client_exception(error, path, http_method)
            # this differentiates between Tomcat returning a 404 (candlepin is down or not deployed)
            # vs a 404 from Candlepin itself
            unless error&.response&.headers&.dig(:x_version)
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
          delegate :[], to: :json_resource

          def resource(url = self.site + self.path, client_cert = self.client_cert, client_key = self.client_key, ca_file = nil, options = {})
            cert_store = OpenSSL::X509::Store.new
            cert_store.add_file(ca_file) if ca_file

            if proxy&.cacert&.present?
              Foreman::Util.add_ca_bundle_to_store(proxy.cacert, cert_store)
            end
            RestClient::Resource.new(url,
                                     :ssl_client_cert => OpenSSL::X509::Certificate.new(client_cert),
                                     :ssl_client_key => OpenSSL::PKey::RSA.new(client_key),
                                     :ssl_cert_store => cert_store,
                                     :verify_ssl => ca_file ? OpenSSL::SSL::VERIFY_PEER : OpenSSL::SSL::VERIFY_NONE,
                                     :open_timeout => Setting[:manifest_refresh_timeout],
                                     :timeout => Setting[:manifest_refresh_timeout],
                                     :proxy => self.proxy_uri,
                                     **options
                                    )
          end

          def json_resource(url = self.site + self.path, client_cert = self.client_cert, client_key = self.client_key, ca_file = nil, options = {})
            options.deep_merge!(headers: self.default_headers)
            resource(url, client_cert, client_key, ca_file, options)
          end

          def rest_client(_http_type = nil, method = :get, path = self.path)
            # No oauth upstream
            self.consumer_secret = nil
            self.consumer_key = nil

            resource(self.site + path, client_cert, client_key, nil, http_method: method)
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
            "#{upstream_api_uri.scheme}://#{upstream_api_uri.host}"
          end

          def upstream_id_cert
            unless upstream_consumer && upstream_consumer['idCert'] && upstream_consumer['idCert']['cert'] && upstream_consumer['idCert']['key']
              Rails.logger.error "Upstream identity certificate not available"
              fail _("Upstream identity certificate not available")
            end
            upstream_consumer['idCert']
          end

          def upstream_owner_id
            JSON.parse(Katello::Resources::Candlepin::UpstreamConsumer.resource.get.body)['owner']['key']
          rescue RestClient::Exception => e
            Rails.logger.error "Unable to find upstream owner for consumer"
            raise e
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
