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
      client.post body, {:accept => :json, :content_type => :json}.merge(User.current.oauth_header)
    end

    def self.delete path
      Rails.logger.debug "Sending DELETE request to Candlepin: #{path}"
      client = CandlepinResource.rest_client(Net::HTTP::Delete, :delete, path_with_cp_prefix(path))
      client.delete({:accept => :json, :content_type => :json}.merge(User.current.oauth_header))
    end

    def self.get path
      Rails.logger.debug "Sending GET request to Candlepin: #{path}"
      client = CandlepinResource.rest_client(Net::HTTP::Get, :get, path_with_cp_prefix(path))
      client.get({:accept => :json}.merge(User.current.oauth_header))
    end

    def self.path_with_cp_prefix path
      CandlepinResource.prefix + path
    end

  end

  class CandlepinResourcePermissions < ::DefaultResourcePermissions
    # /candlepin by default
    self.url_prefix = URI.parse(AppConfig.candlepin.url).path

    # POST /candlepin/owners/ - create new owner
    after_post('/owners/') do |match, request, reply|
      name = JSON.parse(reply)['key']
      verbs = [:create, :read, :update, :delete]
      User.current.allow(verbs, :owner, "owner_#{name}")
    end

    # DELETE /candlepin/owners/ - delete owner
    before_delete('/owners/:name') do |match, request, reply|
      name = match[1]
      User.allowed_to_or_error?(:destroy, :owner, "owner_#{name}")
    end

    after_delete('/owners/:name') do |match, request, reply|
      name = match[1]
      verbs = [:create, :read, :update, :delete]
      User.current.disallow(verbs, :owner, "owner_#{name}")
    end
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
      {'accept' => 'application/json', 'content-type' => 'application/json'}.merge(User.current.oauth_header)
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
        "/candlepin/consumers/#{url_encode id}"
      end

      def get uuid
        JSON.parse(super(path(uuid), self.default_headers).body).with_indifferent_access
      end

      def create name, type, facts
        attrs = {:name => name, :type => type, :facts => facts}
        response = self.post(path(), attrs.to_json, self.default_headers).body
        JSON.parse(response).with_indifferent_access
      end

      def update uuid, facts
        attrs = {:facts => facts}
        response = self.put(path(uuid), attrs.to_json, self.default_headers).body
        # consumer update doesn't return any data atm
        # JSON.parse(response).with_indifferent_access
      end

      def destroy uuid
        self.delete(path(uuid), User.current.oauth_header).code.to_i
      end

      def available_pools(uuid)
        url = Pool.path() + "?consumer=#{uuid}"
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
    end
  end

  class Owner < CandlepinResource

    class << self
      def name_to_key a_name
         a_name.tr(' ', '_')
      end

      # Set the contentPrefic at creation time so that the client will get
      # content only for the org it has been subscribed to
      def create key, description
        attrs = {:key => key, :displayName => description, :contentPrefix => "/#{key}/$env/"}
        owner_json = self.post(path(), attrs.to_json, self.default_headers).body
        JSON.parse(owner_json).with_indifferent_access
      end

      def create_user key, username, password
        attrs = {:username => name_to_key(username), :password => name_to_key(password), :superAdmin => true}
        self.post(join_path(path(key), 'users'), attrs.to_json, self.default_headers).body
      end

      def destroy key
        self.delete(path(key), { 'cp-user' => 'admin' }).code.to_i
      end

      def find key
          owner_json = self.get(path(key), {'cp-user' => 'admin', 'accept' => 'application/json'}).body
          JSON.parse(owner_json).with_indifferent_access
      end

      def update key, organization
        owner = find key
        owner['displayName'] = organization.name
        if organization.parent_id
          owner['parentOwner'] ||= {}
          owner['parentOwner']['id'] = organization.parent_id
        end
        self.put(path(key), JSON.generate(owner), self.default_headers).body
      end

      def import organization_name, path_to_file
        self.post(join_path(path(organization_name), 'imports'),
                             {:import => File.new(path_to_file, 'rb')},
                             self.default_headers)
      end

      def pools key
        if key
          jsonStr = self.get(join_path(path(key), 'pools'), self.default_headers).body
        else
          jsonStr = self.get(join_path('candlepin', 'pools'), self.default_headers).body
        end
        JSON.parse(jsonStr).collect {|p| p.with_indifferent_access }
      end

      def statistics key
        jsonStr = self.get(join_path(path(key), 'statistics'), self.default_headers).body
        JSON.parse(jsonStr).collect {|p| p.with_indifferent_access }
      end

      def path(id=nil)
        "/candlepin/owners/#{url_encode id}"
      end
    end
  end

  class Pool < CandlepinResource
    class << self
      def get pool_id
        pool_json = super(path(pool_id), self.default_headers).body
        JSON.parse(pool_json).with_indifferent_access
      end
      
      def path(id=nil)
        "/candlepin/pools/#{url_encode id}"
      end
    end
  end

  class Content < CandlepinResource
    class << self
      def create attrs
        JSON.parse(self.post(path(), JSON.generate(attrs), self.default_headers).body).with_indifferent_access
      end

      def get id=nil
        content_json = super(path(id), self.default_headers).body
        JSON.parse(content_json).with_indifferent_access
      end

      def destroy id
        raise ArgumentError, "content id has to be specified" unless id
        self.delete(path(id), self.default_headers).code.to_i
      end

      def path(id=nil)
        "/candlepin/content/#{url_encode id}"
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
        self.put("/candlepin/owners/#{owner_key}/subscriptions", {}.to_json, self.default_headers).body
      end

      def path(id=nil)
        "/candlepin/subscriptions/#{url_encode id}"
      end
    end
  end

  class Product < CandlepinResource
    class << self
      def create attr
        JSON.parse(self.post(path(), attr.to_json, self.default_headers).body).with_indifferent_access
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
        self.post(join_path(path(product_id), "content/#{url_encode content_id}?enabled=#{enabled}"), nil, self.default_headers).code.to_i
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

      def delete_subscriptions owner_key, product_id
        subscriptions = Candlepin::Subscription.get_for_owner owner_key
        subscriptions.collect {|s|
          Rails.logger.info "subsc: "+s.to_json
          if s['product']['id'] == product_id
            Candlepin::Subscription.destroy s['id']
          end
          Candlepin::Subscription.refresh_for_owner owner_key
        }
      end

      def path(id=nil)
        "/candlepin/products/#{url_encode id}"
      end
    end
  end

  class Entitlement < CandlepinResource
    class << self
      def regenerate_entitlement_certificates_for_product(product_id)
        self.put("/candlepin/entitlements/product/#{url_encode product_id}", nil, self.default_headers).code.to_i
      end

      def path(id=nil)
        "/candlepin/entitlements/#{url_encode id}"
      end
    end
  end

end
