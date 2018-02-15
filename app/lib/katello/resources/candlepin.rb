require 'katello/util/data'
require 'katello/util/http_proxy'

module Katello
  module Resources
    require 'rest_client'

    module Candlepin
      class Proxy
        def self.logger
          ::Foreman::Logging.logger('katello/cp_proxy')
        end

        def self.post(path, body)
          logger.debug "Sending POST request to Candlepin: #{path}"
          client = CandlepinResource.rest_client(Net::HTTP::Post, :post, path_with_cp_prefix(path))
          client.post body, {:accept => :json, :content_type => :json}.merge(User.cp_oauth_header)
        end

        def self.delete(path, body = nil)
          logger.debug "Sending DELETE request to Candlepin: #{path}"
          client = CandlepinResource.rest_client(Net::HTTP::Delete, :delete, path_with_cp_prefix(path))
          # Some candlepin calls will set the body in DELETE requests.
          client.options[:payload] = body unless body.nil?
          client.delete({:accept => :json, :content_type => :json}.merge(User.cp_oauth_header))
        end

        def self.get(path)
          logger.debug "Sending GET request to Candlepin: #{path}"
          client = CandlepinResource.rest_client(Net::HTTP::Get, :get, path_with_cp_prefix(path))
          client.get({:accept => :json}.merge(User.cp_oauth_header))
        end

        def self.put(path, body)
          logger.debug "Sending PUT request to Candlepin: #{path}"
          client = CandlepinResource.rest_client(Net::HTTP::Put, :put, path_with_cp_prefix(path))
          client.put body, {:accept => :json, :content_type => :json}.merge(User.cp_oauth_header)
        end

        def self.path_with_cp_prefix(path)
          CandlepinResource.prefix + path
        end
      end

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
          headers['X-Correlation-ID'] = request_id.split('-')[0] if request_id

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
          attr_accessor :organization

          def resource(url = self.site + self.path, client_cert = self.client_cert, client_key = self.client_key, ca_file = nil, options = {})
            RestClient.proxy = self.proxy_uri
            RestClient::Resource.new(url,
                                     :ssl_client_cert => OpenSSL::X509::Certificate.new(client_cert),
                                     :ssl_client_key => OpenSSL::PKey::RSA.new(client_key),
                                     :ssl_ca_file => ca_file,
                                     :verify_ssl => ca_file ? OpenSSL::SSL::VERIFY_PEER : OpenSSL::SSL::VERIFY_NONE,
                                     :open_timeout => Setting[:manifest_refresh_timeout],
                                     :timeout => Setting[:manifest_refresh_timeout],
                                     **options
                                    )
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
            @organization ||= Organization.current
            fail _("Current organization not set.") unless @organization
            @upstream_consumer = @organization.owner_details['upstreamConsumer']
            fail _("Current organization has no manifest imported.") unless @upstream_consumer

            @upstream_consumer
          end
        end # class << self
      end # UpstreamCandlepinResource

      class CandlepinPing < CandlepinResource
        class << self
          def ping
            response = get('/candlepin/status').body
            JSON.parse(response).with_indifferent_access
          end

          def distributor_versions
            response = get("/candlepin/distributor_versions").body
            JSON.parse(response)
          end
        end
      end

      class OwnerInfo < CandlepinResource
        class << self
          def find(key)
            owner_json = self.get(path(key), {'accept' => 'application/json'}.merge(User.cp_oauth_header)).body
            JSON.parse(owner_json).with_indifferent_access
          end

          def path(id = nil)
            "/candlepin/owners/#{id}/info"
          end
        end
      end

      class Environment < CandlepinResource
        class << self
          def find(id)
            JSON.parse(self.get(path(id), self.default_headers).body).with_indifferent_access
          end

          def all
            JSON.parse(self.get(path, self.default_headers).body).collect { |a| a.with_indifferent_access }
          end

          def create(owner_id, id, name, description)
            attrs = {:id => id, :name => name, :description => description}
            path = "/candlepin/owners/#{owner_id}/environments"
            environment_json = self.post(path, attrs.to_json, self.default_headers).body
            JSON.parse(environment_json).with_indifferent_access
          end

          def destroy(id)
            self.delete(path(id), User.cp_oauth_header).code.to_i
          end

          def path(id = '')
            "/candlepin/environments/#{id}"
          end

          def add_content(env_id, content_ids)
            path = self.path(env_id) + "/content"
            params = content_ids.map { |content_id| {:contentId => content_id} }
            JSON.parse(self.post(path, params.to_json, self.default_headers).body).with_indifferent_access
          end

          def delete_content(env_id, content_ids)
            path = self.path(env_id) + "/content"
            params = content_ids.map { |content_id| {:content => content_id}.to_param }.join("&")
            self.delete("#{path}?#{params}", self.default_headers).code.to_i
          end
        end
      end

      class CPUser < CandlepinResource
        class << self
          def create(attrs)
            JSON.parse(self.post(path, JSON.generate(attrs), self.default_headers).body).with_indifferent_access
          end

          def path(id = nil)
            "/candlepin/users/#{id}"
          end
        end
      end

      class Content < CandlepinResource
        class << self
          def create(owner_label, attrs)
            JSON.parse(self.post(path(owner_label), JSON.generate(attrs), self.default_headers).body).with_indifferent_access
          end

          def get(owner_label, id)
            content_json = super(path(owner_label, id), self.default_headers).body
            JSON.parse(content_json).with_indifferent_access
          end

          def all(owner_label)
            content_json = Candlepin::CandlepinResource.get(path(owner_label), self.default_headers).body
            JSON.parse(content_json)
          end

          def destroy(owner_label, id)
            fail ArgumentError, "content id has to be specified" unless id
            self.delete(path(owner_label, id), self.default_headers).code.to_i
          end

          def update(owner_label, attrs)
            JSON.parse(self.put(path(owner_label, attrs[:id] || attrs['id']), JSON.generate(attrs), self.default_headers).body).with_indifferent_access
          end

          def path(owner_label, id = nil)
            "/candlepin/owners/#{owner_label}/content/#{id}"
          end
        end
      end

      class Subscription < CandlepinResource
        class << self
          def destroy(subscription_id)
            fail ArgumentError, "subscription id has to be specified" unless subscription_id
            self.delete(path(subscription_id), self.default_headers).code.to_i
          end

          def get(id = nil)
            content_json = super(path(id), self.default_headers).body
            JSON.parse(content_json)
          end

          def create_for_owner(owner_key, attrs)
            subscription = self.post("/candlepin/owners/#{owner_key}/subscriptions", attrs.to_json, self.default_headers).body
            subscription
          end

          def get_for_owner(owner_key, included = [])
            content_json = Candlepin::CandlepinResource.get(
              "/candlepin/owners/#{owner_key}/subscriptions?#{included_list(included)}",
              self.default_headers
            ).body
            JSON.parse(content_json)
          end

          def path(id = nil)
            "/candlepin/subscriptions/#{id}"
          end
        end
      end

      class Job < CandlepinResource
        class << self
          NOT_FINISHED_STATES = %w(CREATED PENDING RUNNING).freeze unless defined? NOT_FINISHED_STATES

          def not_finished?(job)
            NOT_FINISHED_STATES.include?(job[:state])
          end

          def get(id, params = {})
            job_json = super(path(id) + hash_to_query(params), self.default_headers).body
            job = JSON.parse(job_json)
            job.with_indifferent_access
          end

          def path(id = nil)
            "/candlepin/jobs/#{id}"
          end
        end
      end

      class Product < CandlepinResource
        class << self
          def all(owner_label, included = [])
            JSON.parse(Candlepin::CandlepinResource.get(path(owner_label) + "?#{included_list(included)}", self.default_headers).body)
          end

          def find_for_stacking_id(owner_key, stacking_id)
            Subscription.get_for_owner(owner_key).each do |subscription|
              if subscription['product']['attributes'].any? { |attr| attr['name'] == 'stacking_id' && attr['value'] == stacking_id }
                return subscription['product']
              end
            end
            nil
          end

          def create(owner_label, attr)
            JSON.parse(self.post(path(owner_label), attr.to_json, self.default_headers).body).with_indifferent_access
          end

          def get(owner_label, id = nil, included = [])
            products_json = super(path(owner_label, id + "/?#{included_list(included)}"), self.default_headers).body
            products = JSON.parse(products_json)
            products = [products] unless id.nil?
            ::Katello::Util::Data.array_with_indifferent_access products
          end

          def product_certificate(id, owner)
            included = %w(certificate product.id providedProducts.id
                          derivedProvidedProducts.id)
            subscriptions_json = Candlepin::CandlepinResource.get(
              "/candlepin/owners/#{owner}/subscriptions?#{included_list(included)}",
              self.default_headers
            ).body
            subscriptions = JSON.parse(subscriptions_json)

            product_subscription = subscriptions.find do |sub|
              sub['certificate'] &&
              (sub["product"]["id"] == id ||
                sub["providedProducts"].any? { |provided| provided["id"] == id } ||
                sub["derivedProvidedProducts"].any? { |provided| provided["id"] == id })
            end

            if product_subscription
              return product_subscription["certificate"]
            end
          end

          def certificate(id, owner)
            self.product_certificate(id, owner).try :[], 'cert'
          end

          def key(id, owner)
            self.product_certificate(id, owner).try :[], 'key'
          end

          def destroy(owner_label, product_id)
            fail ArgumentError, "product id has to be specified" unless product_id
            self.delete(path(owner_label, product_id), self.default_headers).code.to_i
          end

          def add_content(owner_label, product_id, content_id, enabled)
            self.post(join_path(path(owner_label, product_id), "content/#{content_id}?enabled=#{enabled}"), nil, self.default_headers).code.to_i
          end

          def remove_content(owner_label, product_id, content_id)
            self.delete(join_path(path(owner_label, product_id), "content/#{content_id}"), self.default_headers).code.to_i
          end

          def create_unlimited_subscription(owner_key, product_id, start_date)
            start_date ||= Time.now
            # End it 100 years from now
            end_date ||= start_date + 10_950.days

            subscription = {
              'startDate' => start_date,
              'endDate'   => end_date,
              'quantity'  =>  -1,
              'accountNumber' => '',
              'product' => { 'id' => product_id },
              'providedProducts' => [],
              'contractNumber' => ''
            }
            JSON.parse(Candlepin::Subscription.create_for_owner(owner_key, subscription))
          end

          def pools(owner_key, product_id)
            Candlepin::Pool.get_for_owner(owner_key).find_all { |pool| pool['productId'] == product_id }
          end

          def delete_subscriptions(owner_key, product_id)
            update_subscriptions = false
            subscriptions = Candlepin::Subscription.get_for_owner owner_key
            subscriptions.each do |s|
              products = ([s['product']] + s['providedProducts'])
              products.each do |p|
                if p['id'] == product_id
                  logger.debug "Deleting subscription: " + s.to_json
                  Candlepin::Subscription.destroy s['id']
                  update_subscriptions = true
                end
              end
            end
            nil
          end

          def path(owner_label, id = nil)
            "/candlepin/owners/#{owner_label}/products/#{id}"
          end
        end
      end

      class Entitlement < CandlepinResource
        class << self
          def regenerate_entitlement_certificates_for_product(product_id)
            self.put("/candlepin/entitlements/product/#{product_id}", nil, self.default_headers).code.to_i
          end

          def get(id = nil, params = '')
            json = Candlepin::CandlepinResource.get(path(id) + params, self.default_headers).body
            JSON.parse(json)
          end

          def path(id = nil)
            "/candlepin/entitlements/#{id}"
          end
        end
      end

      class ActivationKey < CandlepinResource
        class << self
          def get(id = nil, params = '')
            akeys_json = super(path(id) + params, self.default_headers).body
            akeys = JSON.parse(akeys_json)
            akeys = [akeys] unless id.nil?
            ::Katello::Util::Data.array_with_indifferent_access akeys
          end

          def create(name, owner_key, auto_attach)
            url = "/candlepin/owners/#{owner_key}/activation_keys"
            JSON.parse(self.post(url, {:name => name, :autoAttach => auto_attach}.to_json, self.default_headers).body).with_indifferent_access
          end

          def update(id, release_version, service_level, auto_attach)
            attrs = { :releaseVer => release_version, :serviceLevel => service_level, :autoAttach => auto_attach }.delete_if { |_k, v| v.nil? }
            JSON.parse(self.put(path(id), attrs.to_json, self.default_headers).body).with_indifferent_access
          end

          def destroy(id)
            fail(ArgumentError, "activation key id has to be specified") unless id
            self.delete(path(id), self.default_headers).code.to_i
          end

          def pools(owner_key)
            Candlepin::Owner.pools(owner_key)
          end

          def key_pools(id)
            kp_json = Candlepin::CandlepinResource.get(join_path(path(id), "pools"), self.default_headers).body
            key_pools = JSON.parse(kp_json)
            ::Katello::Util::Data.array_with_indifferent_access key_pools
          end

          def add_product(id, product_id)
            cppath = join_path(path(id), "product/#{product_id}")
            product = self.post(cppath, {}, self.default_headers)
            JSON.parse(product).with_indifferent_access
          end

          def remove_product(id, product_id)
            product = self.delete(join_path(path(id), "product/#{product_id}"), self.default_headers)
            JSON.parse(product).with_indifferent_access
          end

          def add_pools(id, pool_id, quantity)
            cppath = join_path(path(id), "pools/#{pool_id}")
            quantity = Integer(quantity) rescue nil
            cppath += "?quantity=#{quantity}" if quantity && quantity > 0
            pool = self.post(cppath, {}, self.default_headers)
            JSON.parse(pool).with_indifferent_access
          end

          def remove_pools(id, pool_id)
            pool = self.delete(join_path(path(id), "pools/#{pool_id}"), self.default_headers)
            JSON.parse(pool).with_indifferent_access
          end

          def content_overrides(id)
            result = Candlepin::CandlepinResource.get(join_path(path(id), 'content_overrides'), self.default_headers).body
            ::Katello::Util::Data.array_with_indifferent_access(JSON.parse(result))
          end

          # expected params
          # id : ID of the Activation Key
          # content_overrides => Array of content override hashes
          def update_content_overrides(id, content_overrides)
            attrs_to_delete = []
            attrs_to_update = []
            content_overrides.each do |content_override|
              if content_override[:value]
                attrs_to_update << content_override
              else
                attrs_to_delete << content_override
              end
            end

            if attrs_to_update.present?
              result = Candlepin::CandlepinResource.put(join_path(path(id), 'content_overrides'),
                                                        attrs_to_update.to_json, self.default_headers)
            end
            if attrs_to_delete.present?
              client = Candlepin::CandlepinResource.rest_client(Net::HTTP::Delete, :delete,
                                                                join_path(path(id), 'content_overrides'))
              client.options[:payload] = attrs_to_delete.to_json
              result = client.delete({:accept => :json, :content_type => :json}.merge(User.cp_oauth_header))
            end
            ::Katello::Util::Data.array_with_indifferent_access(JSON.parse(result))
          end

          def path(id = nil)
            "/candlepin/activation_keys/#{id}"
          end
        end
      end
    end
  end
end

Dir["#{File.dirname(__FILE__)}/candlepin/*.rb"].each { |f| require f }
