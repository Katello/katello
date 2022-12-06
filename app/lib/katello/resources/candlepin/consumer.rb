module Katello
  module Resources
    module Candlepin
      class Consumer < CandlepinResource
        extend ConsumerResource

        class << self
          def all_uuids
            cp_consumers = Organization.all.map do |org|
              ::Katello::Resources::Candlepin::Consumer.get('owner' => org.label, :include_only => [:uuid])
            end
            cp_consumers.flatten!
            cp_consumers.map { |consumer| consumer["uuid"] }
          end

          def get(params)
            if params.is_a?(String)
              JSON.parse(super(path(params), self.default_headers).body).with_indifferent_access
            else
              includes = params.key?(:include_only) ? "&" + included_list(params.delete(:include_only)) : ""
              fetch_paged do |page_add|
                response = super(path + hash_to_query(params) + includes + "&#{page_add}", self.default_headers).body
                JSON.parse(response).map(&:with_indifferent_access)
              end
            end
          end

          # workaround for https://bugzilla.redhat.com/1647724
          def get_all_with_facts(uuids)
            consumers = []
            uuids.each do |uuid|
              consumers << get(uuid)
            end
            consumers
          end

          def create(env_ids, parameters, activation_key_cp_ids, org)
            parameters['installedProducts'] ||= [] #if installed products is nil, candlepin won't attach custom products
            parameters['environments'] = env_ids.map { |cp_id| { id: cp_id } }
            url = "/candlepin/consumers/?owner=#{org.label}"
            url += "&activation_keys=" + activation_key_cp_ids.join(",") if activation_key_cp_ids.length > 0

            response = self.post(url, parameters.to_json, self.default_headers).body
            JSON.parse(response).with_indifferent_access
          end

          def async_hypervisors(owner:, reporter_id:, raw_json:)
            url = "/candlepin/hypervisors/#{owner}?reporter_id=#{reporter_id}"
            headers = self.default_headers
            headers['content-type'] = 'text/plain'
            response = self.post(url, raw_json, headers)
            JSON.parse(response).with_indifferent_access
          end

          def hypervisors_heartbeat(owner:, reporter_id:)
            url = "/candlepin/hypervisors/#{owner}/heartbeat?reporter_id=#{reporter_id}"
            response = self.put(url, {}.to_json, self.default_headers).body
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
              if params.key?(:environment) && params[:environment].key?(:id)
                params[:environments] = [{"id": params[:environment][:id]}]
              end
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

          def available_pools(owner_label, uuid, listall: false)
            url = Resources::Candlepin::Pool.path(nil, owner_label) + "?consumer=#{uuid}&listall=#{listall}&add_future=true"
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
            Candlepin::CandlepinResource.get(join_path(path(uuid), 'export'), headers)
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

          def virtual_guests(uuid)
            response = Candlepin::CandlepinResource.get(join_path(path(uuid), 'guests'), self.default_headers).body
            ::Katello::Util::Data.array_with_indifferent_access JSON.parse(response)
          rescue RestClient::Exception
            return []
          end

          def virtual_host(uuid)
            response = Candlepin::CandlepinResource.get(join_path(path(uuid), 'host'), self.default_headers).body
            if response.present?
              JSON.parse(response).with_indifferent_access
            else
              return nil
            end
          rescue RestClient::Exception
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

          def purpose_compliance(uuid)
            response = Candlepin::CandlepinResource.get(join_path(path(uuid), 'purpose_compliance'), self.default_headers(uuid)).body
            if response.present?
              JSON.parse(response).with_indifferent_access
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
    end
  end
end
