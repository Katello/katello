module Katello
  module Resources
    module Candlepin
      class Consumer < CandlepinResource
        extend ConsumerResource

        class << self
          def all_uuids
            cp_consumers = Organization.all.map do |org|
              ::Katello::Resources::Candlepin::Consumer.get('owner' => org.label, :include_only => [:uuid], :sort_by => "uuid")
            end
            cp_consumers.flatten!
            cp_consumers.map { |consumer| consumer["uuid"] }
          end

          def get(params)
            if params.is_a?(String)
              parse_json(super(path(params), headers: self.default_headers))
            else
              params = params.dup
              includes = params.delete(:include_only) || []
              page_size = SETTINGS[:katello][:candlepin][:bulk_load_size]
              page = 0
              content = []
              loop do
                page += 1
                full_path = build_path(path, params: params, includes: includes, page: page, page_size: page_size)
                response = super(full_path, headers: self.default_headers).body
                data = JSON.parse(response).map(&:with_indifferent_access)
                content.concat(data)
                break if data.size < page_size
              end
              content
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

            response = self.post(url, parameters.to_json, headers: self.default_headers).body
            JSON.parse(response).with_indifferent_access
          end

          def async_hypervisors(owner:, reporter_id:, raw_json:)
            url = "/candlepin/hypervisors/#{owner}?reporter_id=#{reporter_id}"
            headers = self.default_headers
            headers['content-type'] = 'text/plain'
            response = self.post(url, raw_json, headers: headers)
            JSON.parse(response.body).with_indifferent_access
          end

          def hypervisors_heartbeat(owner:, reporter_id:)
            url = "/candlepin/hypervisors/#{owner}/heartbeat?reporter_id=#{reporter_id}"
            response = self.put(url, {}.to_json, headers: self.default_headers).body
            JSON.parse(response).with_indifferent_access
          end

          def register_hypervisors(params)
            url = "/candlepin/hypervisors"
            url << "?owner=#{params[:owner]}&env=#{params[:env]}"
            attrs = params.except(:owner, :env)
            response = self.post(url, attrs.to_json, headers: self.default_headers).body
            JSON.parse(response).with_indifferent_access
          end

          def update(uuid, params)
            if params.empty?
              true
            else
              if params.key?(:environment) && params[:environment].key?(:id)
                params[:environments] = [{"id": params[:environment][:id]}]
              end
              self.put(path(uuid), params.to_json, headers: self.default_headers).body
            end
            # consumer update doesn't return any data atm
            # JSON.parse(response).with_indifferent_access
          end

          def destroy(uuid)
            self.delete(path(uuid), headers: User.cp_oauth_header).status
          end

          def serials(uuid)
            response = Candlepin::CandlepinResource.get(join_path(path(uuid), 'certificates/serials'))
            JSON.parse(response.body)
          end

          def checkin(uuid, checkin_date)
            checkin_date ||= Time.now
            self.put(path(uuid), {:lastCheckin => checkin_date}.to_json, headers: self.default_headers).body
          end

          def regenerate_identity_certificates(uuid)
            response = self.post(path(uuid), {}, headers: self.default_headers).body
            JSON.parse(response).with_indifferent_access
          end

          def virtual_guests(uuid)
            response = Candlepin::CandlepinResource.get(join_path(path(uuid), 'guests'), headers: self.default_headers).body
            ::Katello::Util::Data.array_with_indifferent_access JSON.parse(response)
          rescue HttpResource::HttpError
            return []
          end

          def virtual_host(uuid)
            response = Candlepin::CandlepinResource.get(join_path(path(uuid), 'host'), headers: self.default_headers).body
            if response.present?
              JSON.parse(response).with_indifferent_access
            else
              return nil
            end
          rescue HttpResource::HttpError
            return nil
          end

          def content_overrides(id)
            result = Candlepin::CandlepinResource.get(join_path(path(id), 'content_overrides'), headers: self.default_headers).body
            ::Katello::Util::Data.array_with_indifferent_access(JSON.parse(result))
          end

          # expected params
          # id : UUID of the consumer
          # content_overrides => Array of entitlement hashes objects
          def update_content_overrides(id, content_overrides)
            update_content_overrides_for(path(id), id, content_overrides)
          end
        end
      end
    end
  end
end
