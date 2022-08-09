module Katello
  module Resources
    module Candlepin
      class Owner < CandlepinResource
        extend OwnerResource

        class << self
          def all
            response = self.get(path, default_headers)
            JSON.parse(response.body)
          end

          # Set the contentPrefix at creation time so that the client will get
          # content only for the org it has been subscribed to
          def create(key, description, content_access_mode: 'org_environment')
            attrs = {
              :key => key,
              :displayName => description,
              :contentPrefix => "/#{key}/$env",
              :contentAccessMode => content_access_mode,
              :contentAccessModeList => ['entitlement', 'org_environment'].join(',')
            }
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
            owner.merge!(:contentAccessModeList => ['entitlement', 'org_environment'].join(','))
            self.put(path(key), JSON.generate(owner), self.default_headers).body
          end

          def import(organization_name, path_to_file, options)
            path = join_path(path(organization_name), 'imports/async')
            if options[:force] || SETTINGS[:katello].key?(:force_manifest_import)
              path += "?force=#{SETTINGS[:katello][:force_manifest_import]}"
            end

            response = self.post(path, {:import => File.new(path_to_file, 'rb')}, self.default_headers.except('content-type'))
            JSON.parse(response)
          end

          def product_content(organization_name)
            Product.all(organization_name, [:id, :productContent])
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

          def service_levels(uuid)
            response = Candlepin::CandlepinResource.get(join_path(path(uuid), 'servicelevels'), self.default_headers).body
            if response.empty?
              return []
            else
              JSON.parse(response)
            end
          end

          def system_purpose(key)
            response = Candlepin::CandlepinResource.get(join_path(path(key), 'system_purpose'), self.default_headers).body
            if response.empty?
              return []
            else
              JSON.parse(response)['systemPurposeAttributes']
            end
          end
        end
      end
    end
  end
end
