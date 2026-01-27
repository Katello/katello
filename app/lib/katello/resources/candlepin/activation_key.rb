module Katello
  module Resources
    module Candlepin
      class ActivationKey < CandlepinResource
        class << self
          def get(id = nil, params = '', owner = nil)
            akeys_json = super(path(id, owner) + params, self.default_headers).body
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
            response = self.post(url, params.to_json, self.default_headers)
            JSON.parse(response.body).with_indifferent_access
          end

          def update(id, release_version, service_level, purpose_role, purpose_usage)
            attrs = { :releaseVer => release_version, :serviceLevel => service_level, :role => purpose_role, :usage => purpose_usage }.delete_if { |_k, v| v.nil? }
            JSON.parse(self.put(path(id), attrs.to_json, self.default_headers).body).with_indifferent_access
          end

          def destroy(id)
            fail(ArgumentError, "activation key id has to be specified") unless id
            self.delete(path(id), self.default_headers).code.to_i
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
            ::Katello::Util::Data.array_with_indifferent_access(JSON.parse(result || '{}'))
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
