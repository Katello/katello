module Katello
  module Resources
    module Candlepin
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
          rescue RestClient::NotFound => e
            raise ::Katello::Errors::CandlepinEnvironmentGone, e.message
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
    end
  end
end
