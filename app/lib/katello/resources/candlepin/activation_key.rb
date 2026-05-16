module Katello
  module Resources
    module Candlepin
      class ActivationKey < CandlepinResource
        class << self
          def get(id = nil, params = '', owner = nil)
            akeys_json = super(path(id, owner) + params, headers: self.default_headers).body
            akeys = JSON.parse(akeys_json)
            akeys = [akeys] unless id.nil?
            ::Katello::Util::Data.array_with_indifferent_access akeys
          end

          def create(name, owner_key, service_level, release_version, purpose_role, purpose_usage)
            url = "/candlepin/owners/#{owner_key}/activation_keys"
            params = {
              name: name,
              serviceLevel: service_level,
              releaseVer: release_version,
              role: purpose_role,
              usage: purpose_usage,
            }
            response = self.post(url, params.to_json, headers: self.default_headers)
            JSON.parse(response.body).with_indifferent_access
          end

          def update(id, release_version, service_level, purpose_role, purpose_usage)
            attrs = { :releaseVer => release_version, :serviceLevel => service_level, :role => purpose_role, :usage => purpose_usage }.delete_if { |_k, v| v.nil? }
            JSON.parse(self.put(path(id), attrs.to_json, headers: self.default_headers).body).with_indifferent_access
          end

          def destroy(id)
            fail(ArgumentError, "activation key id has to be specified") unless id
            self.delete(path(id), headers: self.default_headers).status
          end

          def content_overrides(id)
            result = Candlepin::CandlepinResource.get(join_path(path(id), 'content_overrides'), headers: self.default_headers).body
            ::Katello::Util::Data.array_with_indifferent_access(JSON.parse(result))
          end

          # expected params
          # id : ID of the Activation Key
          # content_overrides => Array of content override hashes
          def update_content_overrides(id, content_overrides)
            update_content_overrides_for(path(id), id, content_overrides)
          end

          def path(id = nil, owner_id = nil)
            if owner_id
              "/candlepin/owners/#{owner_id}/activation_keys/#{id}"
            else
              "/candlepin/activation_keys/#{id}"
            end
          end
        end
      end
    end
  end
end
