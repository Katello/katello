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

require 'rubygems'
require 'rest_client'
require 'resource_permissions'
require 'http_resource'

module Candlepin

  class Proxy
    def self.post path, body
      Rails.logger.debug "Sending POST request to Candlepin: #{path}"
      client = CandlepinResource.rest_client(Net::HTTP::Post, :post, path_with_cp_prefix(path))
      client.post body, {:accept => :json, :content_type => :json}.merge(User.cp_oauth_header)
    end

    def self.delete path
      Rails.logger.debug "Sending DELETE request to Candlepin: #{path}"
      client = CandlepinResource.rest_client(Net::HTTP::Delete, :delete, path_with_cp_prefix(path))
      client.delete({:accept => :json, :content_type => :json}.merge(User.cp_oauth_header))
    end

    def self.get path
      Rails.logger.debug "Sending GET request to Candlepin: #{path}"
      client = CandlepinResource.rest_client(Net::HTTP::Get, :get, path_with_cp_prefix(path))
      client.get({:accept => :json}.merge(User.cp_oauth_header))
    end

    def self.path_with_cp_prefix path
      CandlepinResource.prefix + path
    end

  end

  class CandlepinResourcePermissions < ::DefaultResourcePermissions
    # /candlepin by default
    self.url_prefix = URI.parse(AppConfig.candlepin.url).path

  end

  class CandlepinResource < ::HttpResource
    cfg = AppConfig.candlepin
    url = cfg.url
    self.prefix = URI.parse(url).path
    self.site = url.gsub(self.prefix, "")
    self.consumer_secret = cfg.oauth_secret
    self.consumer_key = cfg.oauth_key
    self.ca_cert_file = cfg.ca_cert_file
    self.resource_permissions = CandlepinResourcePermissions

    def self.default_headers
      {'accept' => 'application/json',
       'accept-language' => I18n.locale,
       'content-type' => 'application/json'}.merge(User.cp_oauth_header)
    end

    def self.name_to_key a_name
      a_name.tr(' ', '_')
    end
  end

  class CandlepinPing < CandlepinResource
    class << self
      def ping
        response = get('/candlepin/status').body
        JSON.parse(response).with_indifferent_access
      end
    end
  end

  class Consumer < CandlepinResource
    class << self
      def export
        response = Candlepin::CandlepinResource.get(join_path(path(), 'export'), {:accept => '*/*'})
        filename = response.headers[:content_disposition] == nil ? "tmp_#{rand}.zip" : response.headers[:content_disposition].split("filename=")[1]
        File.open(filename, 'w') { |f| f.write(response) }
      end

      def path(id=nil)
        "/candlepin/consumers/#{id}"
      end

      def get uuid
        JSON.parse(super(path(uuid), self.default_headers).body).with_indifferent_access
      end

      def create env_id, key, name, type, facts, installedProducts, autoheal=true, releaseVer=nil, service_level=""
        url = "/candlepin/environments/#{url_encode(env_id)}/consumers/"
        attrs = {:name => name,
                 :type => type,
                 :facts => facts,
                 :installedProducts => installedProducts,
                 :autoheal => autoheal,
                 :releaseVer => releaseVer,
                 :serviceLevel => service_level}
        response = self.post(url, attrs.to_json, self.default_headers).body
        JSON.parse(response).with_indifferent_access
      end

      def register_hypervisors params
        url = "/candlepin/hypervisors"
        url << "?owner=#{params[:owner]}&env=#{params[:env]}"
        attrs = params.except(:owner, :env)
        response = self.post(url, attrs.to_json, self.default_headers).body
        JSON.parse(response).with_indifferent_access
      end

      def update(uuid, facts, guest_ids = nil, installedProducts = nil, autoheal = nil, releaseVer = nil, service_level=nil)
        attrs = {:facts => facts,
                 :guestIds => guest_ids,
                 :releaseVer => releaseVer,
                 :installedProducts => installedProducts,
                 :autoheal => autoheal,
                 :serviceLevel => service_level}.delete_if {|k,v| v.nil?}
        unless attrs.empty?
          response = self.put(path(uuid), attrs.to_json, self.default_headers).body
        else[]
          return true
        end
        # consumer update doesn't return any data atm
        # JSON.parse(response).with_indifferent_access
      end

      def destroy uuid
        self.delete(path(uuid), User.cp_oauth_header).code.to_i
      end

      def available_pools(uuid, listall=false)
        url = Pool.path() + "?consumer=#{uuid}&listall=#{listall}"
        response = Candlepin::CandlepinResource.get(url,self.default_headers).body
        JSON.parse(response)
      end


      def regenerate_identity_certificates uuid
        response = self.post(path(uuid), {}, self.default_headers).body
        JSON.parse(response).with_indifferent_access
      end

      def entitlements uuid
        response = Candlepin::CandlepinResource.get(join_path(path(uuid), 'entitlements'), self.default_headers).body
        JSON.parse(response).collect { |e| e.with_indifferent_access }
      end

      def consume_entitlement uuid, pool, quantity = nil
        uri = join_path(path(uuid), 'entitlements') + "?pool=#{pool}"
        uri += "&quantity=#{quantity}" if quantity
        self.post(uri, "", self.default_headers).body
      end

      def remove_entitlement uuid, ent_id
        uri = join_path(path(uuid), 'entitlements') + "/#{ent_id}"
        self.delete(uri, self.default_headers).code.to_i
      end

      def remove_entitlements uuid
        uri = join_path(path(uuid), 'entitlements')
        self.delete(uri, self.default_headers).code.to_i
      end

      def remove_certificate uuid, serial_id
        uri = join_path(path(uuid), 'certificates') + "/#{serial_id}"
        self.delete(uri, self.default_headers).code.to_i
      end

      def guests uuid
        response = Candlepin::CandlepinResource.get(join_path(path(uuid), 'guests'), self.default_headers).body
        JSON.parse(response).map { |e| e.with_indifferent_access }
      rescue Exception => e
        return []
      end

      def host uuid
        response = Candlepin::CandlepinResource.get(join_path(path(uuid), 'host'), self.default_headers).body
        unless response.empty?
          JSON.parse(response).with_indifferent_access
        else
          return nil
        end
      rescue Exception => e
        return nil
      end

      def compliance uuid
        response = Candlepin::CandlepinResource.get(join_path(path(uuid), 'compliance'), self.default_headers).body
        unless response.empty?
          JSON.parse(response).with_indifferent_access
        else
          return nil
        end
      end

      def events uuid
        response = Candlepin::CandlepinResource.get(join_path(path(uuid), 'events'), self.default_headers).body
        unless response.empty?
          JSON.parse(response).collect {|s| s.with_indifferent_access}
        else
          return []
        end
      end
    end
  end

  class OwnerInfo < CandlepinResource
    class << self

      def find key
          owner_json = self.get(path(key), {'accept' => 'application/json'}.merge(User.cp_oauth_header)).body
          JSON.parse(owner_json).with_indifferent_access
      end

      def path(id=nil)
        "/candlepin/owners/#{id}/info"
      end
    end
  end


  class Owner < CandlepinResource
    class << self
      # Set the contentPrefix at creation time so that the client will get
      # content only for the org it has been subscribed to
      def create key, description
        attrs = {:key => key, :displayName => description, :contentPrefix => (AppConfig.katello? ? "/#{key}/$env" : "")}
        owner_json = self.post(path(), attrs.to_json, self.default_headers).body
        JSON.parse(owner_json).with_indifferent_access
      end

      # create the first user for owner
      def create_user key, username, password
        # create user with superadmin flag (no role, permissions etc)
        CPUser.create({:username => name_to_key(username), :password => name_to_key(password), :superAdmin => true})
      end

      def destroy key
        self.delete(path(key), User.cp_oauth_header).code.to_i
      end

      def find key
          owner_json = self.get(path(key), {'accept' => 'application/json'}.merge(User.cp_oauth_header)).body
          JSON.parse(owner_json).with_indifferent_access
      end

      def update key, organization
        owner = find key
        owner['displayName'] = organization.name
        self.put(path(key), JSON.generate(owner), self.default_headers).body
      end

      def import organization_name, path_to_file, options
        path = join_path(path(organization_name), 'imports')

        query_params = {}
        query_params[:force] = true if options[:force] == "true"
        unless query_params.empty?
          path << "?" << query_params.to_param
        end

        self.post(path, {:import => File.new(path_to_file, 'rb')}, self.default_headers.except('content-type'))
      end

      def imports organization_name
        imports_json = self.get(join_path(path(organization_name), 'imports'), self.default_headers)
        JSON.parse(imports_json).collect {|s| s.with_indifferent_access}
      end

      def pools key, filter = {}
        if key
          jsonStr = self.get(join_path(path(key), 'pools') + hash_to_query(filter), self.default_headers).body
        else
          jsonStr = self.get(join_path('candlepin', 'pools') + hash_to_query(filter), self.default_headers).body
        end
        JSON.parse(jsonStr).collect {|p| p.with_indifferent_access }
      end

      def statistics key
        jsonStr = self.get(join_path(path(key), 'statistics'), self.default_headers).body
        JSON.parse(jsonStr).collect {|p| p.with_indifferent_access }
      end

      def generate_ueber_cert key
        ueber_cert_json = self.post(join_path(path(key), "uebercert"), {}.to_json, self.default_headers).body
        JSON.parse(ueber_cert_json).with_indifferent_access
      end

      def get_ueber_cert key
        ueber_cert_json = self.get(join_path(path(key), "uebercert"), {'accept' => 'application/json'}.merge(User.cp_oauth_header)).body
        JSON.parse(ueber_cert_json).with_indifferent_access
      end

      def get_ueber_cert_pkcs12 key, name = nil, password = nil
        certs = get_ueber_cert(key)
        c =  OpenSSL::X509::Certificate.new certs["cert"]
        p = OpenSSL::PKey::RSA.new certs["key"]
        OpenSSL::PKCS12.create(password, name, p, c,nil, "PBE-SHA1-3DES" ,"PBE-SHA1-3DES")
      end

      def events key
        response = self.get(join_path(path(key), 'events'), self.default_headers).body
        JSON.parse(response).collect { |e| e.with_indifferent_access }
      end

      def service_levels uuid
        response = Candlepin::CandlepinResource.get(join_path(path(uuid), 'servicelevels'), self.default_headers).body
        unless response.empty?
          JSON.parse(response)
        else
          return []
        end
      end

      def path(id=nil)
        "/candlepin/owners/#{id}"
      end
    end
  end

  class Environment < CandlepinResource
    class << self

      def find id
        JSON.parse(self.get(path(id), self.default_headers).body).with_indifferent_access
      end


      def create owner_id, id, name, description
        attrs = {:id => id, :name => name, :description => description}
        path = "/candlepin/owners/#{owner_id}/environments"
        environment_json = self.post(path, attrs.to_json, self.default_headers).body
        JSON.parse(environment_json).with_indifferent_access
      end

      def destroy id
        self.delete(path(id), User.cp_oauth_header).code.to_i
      end

      def path(id)
        "/candlepin/environments/#{id}"
      end

      def add_content(env_id, content_ids)
        path = self.path(env_id) + "/content"
        params = content_ids.map {|content_id| {:contentId => content_id} }
        JSON.parse(self.post(path, params.to_json, self.default_headers).body).with_indifferent_access
      end

      def delete_content(env_id, content_ids)
        path = self.path(env_id) + "/content"
        params = content_ids.map {|content_id| {:content => content_id}.to_param }.join("&")
        self.delete("#{path}?#{params}", self.default_headers).code.to_i
      end
    end
  end

  class CPUser < CandlepinResource
    class << self
      def create attrs
        JSON.parse(self.post(path(), JSON.generate(attrs), self.default_headers).body).with_indifferent_access
      end

      def path(id=nil)
        "/candlepin/users/#{id}"
      end
    end
  end

  class Pool < CandlepinResource
    class << self
      def find pool_id
        pool_json = self.get(path(pool_id), self.default_headers).body
        JSON.parse(pool_json).with_indifferent_access
      end

      def get_for_owner owner_key
        pools_json = self.get("/candlepin/owners/#{owner_key}/pools", self.default_headers).body
        JSON.parse(pools_json)
      end

      def destroy id
        raise ArgumentError, "pool id has to be specified" unless id
        self.delete(path(id), self.default_headers).code.to_i
      end

      def path id=nil
        "/candlepin/pools/#{id}"
      end
    end
  end

  class Content < CandlepinResource
    class << self
      def create attrs
        JSON.parse(self.post(path(), JSON.generate(attrs), self.default_headers).body).with_indifferent_access
      end

      def get id
        content_json = super(path(id), self.default_headers).body
        JSON.parse(content_json).with_indifferent_access
      end

      def all
        content_json = Candlepin::CandlepinResource.get(path(), self.default_headers).body
        JSON.parse(content_json)
      end

      def destroy id
        raise ArgumentError, "content id has to be specified" unless id
        self.delete(path(id), self.default_headers).code.to_i
      end

      def path(id=nil)
        "/candlepin/content/#{id}"
      end
    end
  end

  class Subscription < CandlepinResource
    class << self

      def destroy subscription_id
        raise ArgumentError, "subscription id has to be specified" unless subscription_id
        self.delete(path(subscription_id), self.default_headers).code.to_i
      end

      def get id=nil
        content_json = super(path(id), self.default_headers).body
        content = JSON.parse(content_json)
      end

      def create_for_owner owner_key, attrs
        subscription = self.post("/candlepin/owners/#{owner_key}/subscriptions", attrs.to_json, self.default_headers).body
        self.put("/candlepin/owners/#{owner_key}/subscriptions", {}.to_json, self.default_headers).body
        subscription
      end

      def get_for_owner owner_key
        content_json = Candlepin::CandlepinResource.get("/candlepin/owners/#{owner_key}/subscriptions", self.default_headers).body
        content = JSON.parse(content_json)
      end

      def refresh_for_owner owner_key
        ret = self.put("/candlepin/owners/#{owner_key}/subscriptions", {}.to_json, self.default_headers).body
        JSON.parse(ret).with_indifferent_access
      end

      def path(id=nil)
        "/candlepin/subscriptions/#{id}"
      end
    end
  end

  class Job < CandlepinResource
    class << self

      NOT_FINISHED_STATES = %w[CREATED PENDING RUNNING] unless defined? NOT_FINISHED_STATES

      def not_finished?(job)
        NOT_FINISHED_STATES.include?(job[:state])
      end

      def get id
        job_json = super(path(id), self.default_headers).body
        job = JSON.parse(job_json)
        job.with_indifferent_access
      end

      def path(id=nil)
        "/candlepin/jobs/#{id}"
      end
    end
  end

  class Product < CandlepinResource
    class << self

      def all
        JSON.parse(Candlepin::CandlepinResource.get(path, self.default_headers).body)
      end

      def create attr
        JSON.parse(self.post(path, attr.to_json, self.default_headers).body).with_indifferent_access
      end

      def get id=nil
        products_json = super(path(id), self.default_headers).body
        products = JSON.parse(products_json)
        products = [products] unless id.nil?
        products.collect {|p| p.with_indifferent_access }
      end


      def _certificate_and_key id
        subscriptions_json = Candlepin::CandlepinResource.get('/candlepin/subscriptions', self.default_headers).body
        subscriptions = JSON.parse(subscriptions_json)

        for sub in subscriptions
          if sub["product"]["id"] == id
            return sub["certificate"]
          end

          for provProds in sub["providedProducts"]
            if provProds["id"] == id
              return sub["certificate"]
            end
          end
        end
        nil
      end

      def certificate id
        self._certificate_and_key(id)["cert"]
      end

      def key id
        self._certificate_and_key(id)["key"]
      end

      def destroy product_id
        raise ArgumentError, "product id has to be specified" unless product_id
        self.delete(path(product_id), self.default_headers).code.to_i
      end

      def add_content product_id, content_id, enabled
        self.post(join_path(path(product_id), "content/#{content_id}?enabled=#{enabled}"), nil, self.default_headers).code.to_i
      end

      def remove_content product_id, content_id
        self.delete(join_path(path(product_id), "content/#{content_id}"), self.default_headers).code.to_i
      end

      def create_unlimited_subscription owner_key, product_id
        start_date ||= Date.today
        # End it 100 years from now
        end_date ||= start_date + 10950

        subscription = {
          'startDate' => start_date,
          'endDate'   => end_date,
          'quantity'  =>  -1,
          'accountNumber' => '',
          'product' => { 'id' => product_id },
          'providedProducts' => [],
          'contractNumber' => ''
        }
        Candlepin::Subscription.create_for_owner owner_key, subscription
      end

      def pools owner_key, product_id
        Candlepin::Pool.get_for_owner(owner_key).find_all {|pool| pool['productId'] == product_id }
      end

      def delete_subscriptions owner_key, product_id
        update_subscriptions = false
        subscriptions = Candlepin::Subscription.get_for_owner owner_key
        subscriptions.each do |s|
          products = ([s['product']] + s['providedProducts'])
          products.each do |p|
            if p['id'] == product_id
              Rails.logger.debug "Deleting subscription: " + s.to_json
              Candlepin::Subscription.destroy s['id']
              update_subscriptions = true
            end
          end
        end

        if update_subscriptions
          return Candlepin::Subscription.refresh_for_owner owner_key
        else
          return nil
        end
      end

      def path(id=nil)
        "/candlepin/products/#{id}"
      end
    end
  end

  class Entitlement < CandlepinResource
    class << self
      def regenerate_entitlement_certificates_for_product(product_id)
        self.put("/candlepin/entitlements/product/#{product_id}", nil, self.default_headers).code.to_i
      end

      def path(id=nil)
        "/candlepin/entitlements/#{id}"
      end
    end
  end

end
