require 'katello/util/data'

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
        self.prefix = URI.parse(url).path
        self.site = url.gsub(self.prefix, "")
        self.consumer_secret = cfg[:oauth_secret]
        self.consumer_key = cfg[:oauth_key]
        self.ca_cert_file = cfg[:ca_cert_file]

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

          {'accept' => 'application/json',
           'accept-language' => I18n.locale,
           'content-type' => 'application/json'}.merge(cp_oauth_header)
        end

        def self.name_to_key(a_name)
          a_name.tr(' ', '_')
        end

        def self.included_list(included)
          included.map { |value| "include=#{value}" }.join('&')
        end
      end

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

      class Consumer < CandlepinResource
        class << self
          def path(id = nil)
            "/candlepin/consumers/#{id}"
          end

          def get(params)
            if params.is_a?(String)
              JSON.parse(super(path(params), self.default_headers).body).with_indifferent_access
            else
              response = super(path + hash_to_query(params), self.default_headers).body
              JSON.parse(response)
            end
          end

          def create(env_id, parameters, activation_key_cp_ids)
            parameters['installedProducts'] ||= [] #if installed products is nil, candlepin won't attach custom products
            url = "/candlepin/environments/#{url_encode(env_id)}/consumers/"
            url += "?activation_keys=" + activation_key_cp_ids.join(",") if activation_key_cp_ids.length > 0

            response = self.post(url, parameters.to_json, self.default_headers).body
            JSON.parse(response).with_indifferent_access
          end

          def register_hypervisors(params)
            url = "/candlepin/hypervisors"
            url << "?owner=#{params[:owner]}&env=#{params[:env]}"
            attrs = params.except(:owner, :env)
            response = self.post(url, attrs.to_json, self.default_headers).body
            JSON.parse(response).with_indifferent_access
          end

          def update(uuid, params)
            if params.empty?
              true
            else
              self.put(path(uuid), params.to_json, self.default_headers).body
            end
            # consumer update doesn't return any data atm
            # JSON.parse(response).with_indifferent_access
          end

          def destroy(uuid)
            self.delete(path(uuid), User.cp_oauth_header).code.to_i
          end

          def serials(uuid)
            response = Candlepin::CandlepinResource.get(join_path(path(uuid), 'certificates/serials'))
            JSON.parse(response.body)
          end

          def checkin(uuid, checkin_date)
            checkin_date ||= Time.now
            self.put(path(uuid), {:lastCheckin => checkin_date}.to_json, self.default_headers).body
          end

          def available_pools(owner_label, uuid, listall = false)
            url = Pool.path(nil, owner_label) + "?consumer=#{uuid}&listall=#{listall}"
            response = Candlepin::CandlepinResource.get(url, self.default_headers).body
            JSON.parse(response)
          end

          def regenerate_identity_certificates(uuid)
            response = self.post(path(uuid), {}, self.default_headers).body
            JSON.parse(response).with_indifferent_access
          end

          def export(uuid)
            # Export is a zip file
            headers = self.default_headers
            headers['accept'] = 'application/zip'
            response = Candlepin::CandlepinResource.get(join_path(path(uuid), 'export'), headers)
            response
          end

          def entitlements(uuid)
            response = Candlepin::CandlepinResource.get(join_path(path(uuid), 'entitlements'), self.default_headers).body
            ::Katello::Util::Data.array_with_indifferent_access JSON.parse(response)
          end

          def refresh_entitlements(uuid)
            self.post(join_path(path(uuid), 'entitlements'), "", self.default_headers).body
          end

          def consume_entitlement(uuid, pool, quantity = nil)
            uri = join_path(path(uuid), 'entitlements') + "?pool=#{pool}"
            uri += "&quantity=#{quantity}" if quantity && quantity > 0
            response = self.post(uri, "", self.default_headers).body
            response.blank? ? [] : JSON.parse(response)
          end

          def remove_entitlement(uuid, ent_id)
            uri = join_path(path(uuid), 'entitlements') + "/#{ent_id}"
            self.delete(uri, self.default_headers).code.to_i
          end

          def remove_entitlements(uuid)
            uri = join_path(path(uuid), 'entitlements')
            self.delete(uri, self.default_headers).code.to_i
          end

          def remove_certificate(uuid, serial_id)
            uri = join_path(path(uuid), 'certificates') + "/#{serial_id}"
            self.delete(uri, self.default_headers).code.to_i
          end

          def virtual_guests(uuid)
            response = Candlepin::CandlepinResource.get(join_path(path(uuid), 'guests'), self.default_headers).body
            ::Katello::Util::Data.array_with_indifferent_access JSON.parse(response)
          rescue
            return []
          end

          def virtual_host(uuid)
            response = Candlepin::CandlepinResource.get(join_path(path(uuid), 'host'), self.default_headers).body
            if response.present?
              JSON.parse(response).with_indifferent_access
            else
              return nil
            end
          rescue
            return nil
          end

          def compliance(uuid)
            response = Candlepin::CandlepinResource.get(join_path(path(uuid), 'compliance'), self.default_headers(uuid)).body
            if response.present?
              json = JSON.parse(response).with_indifferent_access
              if json['reasons']
                json['reasons'].sort! { |x, y| x['attributes']['name'] <=> y['attributes']['name'] }
              else
                json['reasons'] = []
              end
              json
            else
              return nil
            end
          end

          def events(uuid)
            response = Candlepin::CandlepinResource.get(join_path(path(uuid), 'events'), self.default_headers).body
            if response.present?
              ::Katello::Util::Data.array_with_indifferent_access JSON.parse(response)
            else
              return []
            end
          end

          def content_overrides(id)
            result = Candlepin::CandlepinResource.get(join_path(path(id), 'content_overrides'), self.default_headers).body
            ::Katello::Util::Data.array_with_indifferent_access(JSON.parse(result))
          end

          # expected params
          # id : UUID of the consumer
          # content_overrides => Array of entitlement hashes objects
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
        end
      end

      class UpstreamConsumer < HttpResource
        def self.logger
          ::Foreman::Logging.logger('katello/cp_rest')
        end

        def self.resource(url, client_cert, client_key, ca_file)
          if SETTINGS[:katello][:cdn_proxy] && SETTINGS[:katello][:cdn_proxy][:host]
            proxy_config = SETTINGS[:katello][:cdn_proxy]
            uri = URI('')

            uri.scheme = URI.parse(proxy_config[:host]).scheme
            uri.host = URI.parse(proxy_config[:host]).host
            uri.port = proxy_config[:port].to_s
            uri.user = proxy_config[:user].to_s
            uri.password = proxy_config[:password].to_s

            RestClient.proxy = uri.to_s
          end

          RestClient::Resource.new(url,
                                   :ssl_client_cert => OpenSSL::X509::Certificate.new(client_cert),
                                   :ssl_client_key => OpenSSL::PKey::RSA.new(client_key),
                                   :ssl_ca_file => ca_file,
                                   :verify_ssl => ca_file ? OpenSSL::SSL::VERIFY_PEER : OpenSSL::SSL::VERIFY_NONE
                                  )
        end

        def self.export(url, client_cert, client_key, ca_file)
          logger.debug "Sending GET request to upstream Candlepin: #{url}"
          return resource(url, client_cert, client_key, ca_file).get
        rescue => e
          raise e
        ensure
          RestClient.proxy = ""
        end

        def self.update(url, client_cert, client_key, ca_file, attributes)
          logger.debug "Sending POST request to upstream Candlepin: #{url} #{attributes.to_json}"

          return resource(url, client_cert, client_key, ca_file).put(attributes.to_json,
                                                                     'accept' => 'application/json',
                                                                     'accept-language' => I18n.locale,
                                                                     'content-type' => 'application/json')
        ensure
          RestClient.proxy = ""
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

      class Owner < CandlepinResource
        class << self
          # Set the contentPrefix at creation time so that the client will get
          # content only for the org it has been subscribed to
          def create(key, description)
            attrs = {:key => key, :displayName => description, :contentPrefix => "/#{key}/$env"}
            owner_json = self.post(path, attrs.to_json, self.default_headers).body
            JSON.parse(owner_json).with_indifferent_access
          end

          # create the first user for owner
          def create_user(_key, username, password)
            # create user with superadmin flag (no role, permissions etc)
            CPUser.create(:username => name_to_key(username), :password => name_to_key(password), :superAdmin => true)
          end

          def destroy(key)
            self.delete(path(key), User.cp_oauth_header).code.to_i
          end

          def find(key)
            owner_json = self.get(path(key), {'accept' => 'application/json'}.merge(User.cp_oauth_header)).body
            JSON.parse(owner_json).with_indifferent_access
          end

          def update(key, attrs)
            owner = find(key)
            owner.merge!(attrs)
            self.put(path(key), JSON.generate(owner), self.default_headers).body
          end

          def import(organization_name, path_to_file, options)
            path = join_path(path(organization_name), 'imports')
            if options[:force] || SETTINGS[:katello].key?(:force_manifest_import)
              path += "?force=#{SETTINGS[:katello][:force_manifest_import]}"
            end

            self.post(path, {:import => File.new(path_to_file, 'rb')}, self.default_headers.except('content-type'))
          end

          def destroy_imports(organization_name, wait_until_complete = false)
            response_json = self.delete(join_path(path(organization_name), 'imports'), self.default_headers)
            response = JSON.parse(response_json).with_indifferent_access
            if wait_until_complete && response['state'] == 'CREATED'
              while !response['state'].nil? && response['state'] != 'FINISHED' && response['state'] != 'ERROR'
                path = join_path('candlepin', response['statusPath'][1..-1])
                response_json = self.get(path, self.default_headers)
                response = JSON.parse(response_json).with_indifferent_access
              end
            end

            response
          end

          def imports(organization_name)
            imports_json = self.get(join_path(path(organization_name), 'imports'), self.default_headers)
            ::Katello::Util::Data.array_with_indifferent_access JSON.parse(imports_json)
          end

          def pools(owner_label, filter = {})
            filter[:add_future] ||= true
            params = hash_to_query(filter)
            if owner_label
              # hash_to_query escapes the ":!" to "%3A%21" which candlepin rejects
              params += '&attribute=unmapped_guests_only:!true'
              json_str = self.get(join_path(path(owner_label), 'pools') + params, self.default_headers).body
            else
              json_str = self.get(join_path('candlepin', 'pools') + params, self.default_headers).body
            end
            ::Katello::Util::Data.array_with_indifferent_access JSON.parse(json_str)
          end

          def statistics(key)
            json_str = self.get(join_path(path(key), 'statistics'), self.default_headers).body
            ::Katello::Util::Data.array_with_indifferent_access JSON.parse(json_str)
          end

          def generate_ueber_cert(key)
            ueber_cert_json = self.post(join_path(path(key), "uebercert"), {}.to_json, self.default_headers).body
            JSON.parse(ueber_cert_json).with_indifferent_access
          end

          def get_ueber_cert(key)
            ueber_cert_json = self.get(join_path(path(key), "uebercert"), {'accept' => 'application/json'}.merge(User.cp_oauth_header)).body
            JSON.parse(ueber_cert_json).with_indifferent_access
          end

          def get_ueber_cert_pkcs12(key, name = nil, password = nil)
            certs = get_ueber_cert(key)
            c = OpenSSL::X509::Certificate.new certs["cert"]
            p = OpenSSL::PKey::RSA.new certs["key"]
            OpenSSL::PKCS12.create(password, name, p, c, nil, "PBE-SHA1-3DES", "PBE-SHA1-3DES")
          end

          def events(key)
            response = self.get(join_path(path(key), 'events'), self.default_headers).body
            ::Katello::Util::Data.array_with_indifferent_access JSON.parse(response)
          end

          def service_levels(uuid)
            response = Candlepin::CandlepinResource.get(join_path(path(uuid), 'servicelevels'), self.default_headers).body
            if response.empty?
              return []
            else
              JSON.parse(response)
            end
          end

          def auto_attach(key)
            response = self.post(join_path(path(key), 'entitlements'), "", self.default_headers).body
            if response.empty?
              return nil
            else
              JSON.parse(response)
            end
          end

          def path(id = nil)
            "/candlepin/owners/#{id}"
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

      class Pool < CandlepinResource
        class << self
          def find(pool_id)
            pool_json = self.get(path(pool_id), self.default_headers).body
            fail ArgumentError, "pool id cannot contain ?" if pool_id["?"]
            JSON.parse(pool_json).with_indifferent_access
          end

          def get_for_owner(owner_key, include_temporary_guests = false)
            url = "/candlepin/owners/#{owner_key}/pools?add_future=true"
            url += "&attribute=unmapped_guests_only:!true" if include_temporary_guests
            pools_json = self.get(url, self.default_headers).body
            JSON.parse(pools_json)
          end

          def destroy(id)
            fail ArgumentError, "pool id has to be specified" unless id
            self.delete(path(id), self.default_headers).code.to_i
          end

          def entitlements(pool_id)
            entitlement_json = self.get("#{path(pool_id)}/entitlements", self.default_headers).body
            JSON.parse(entitlement_json)
          end

          def path(id = nil, owner_label = nil)
            if owner_label && id
              "/candlepin/owners/#{owner_label}/pools/#{id}"
            elsif owner_label
              "/candlepin/owners/#{owner_label}/pools/"
            else
              "/candlepin/pools/#{id}"
            end
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

          def get(id)
            job_json = super(path(id), self.default_headers).body
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
          def all(owner_label)
            JSON.parse(Candlepin::CandlepinResource.get(path(owner_label), self.default_headers).body)
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
              sub["product"]["id"] == id ||
                sub["providedProducts"].any? { |provided| provided["id"] == id } ||
                sub["derivedProvidedProducts"].any? { |provided| provided["id"] == id }
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

          def create_unlimited_subscription(owner_key, product_id)
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
