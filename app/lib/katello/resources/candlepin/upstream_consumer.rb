module Katello
  module Resources
    module Candlepin
      class UpstreamConsumer < UpstreamCandlepinResource
        extend ConsumerResource

        class << self
          def path(id = upstream_consumer_id)
            super(id)
          end

          def ping
            issue_request(method: :head, path: path, headers: default_headers, process: false)
          rescue HttpResource::HttpError => e
            raise ::Katello::Errors::UpstreamConsumerGone if %w(401 410).include?(e.code)
            raise ::Katello::Errors::UpstreamConsumerNotFound if e.code == '404'
            raise e
          end

          def get(params)
            includes = params.key?(:include_only) ? "&" + included_list(params.delete(:include_only)) : ""
            JSON.parse(super(path + hash_to_query(params) + includes, headers: self.default_headers).body)
          rescue HttpResource::HttpError => e
            raise ::Katello::Errors::UpstreamConsumerGone if e.code == '410'
            raise e
          end

          def remove_entitlement(entitlement_id)
            fail ArgumentError, "No entitlement ID given to remove." if entitlement_id.blank?
            self.delete(join_path(path, "entitlements/#{entitlement_id}"), headers: self.default_headers)
          rescue HttpResource::HttpError => e
            raise ::Katello::Errors::UpstreamEntitlementGone if e.code == '404'
            raise e
          end

          def start_upstream_export(url, client_cert, client_key, ca_file)
            conn = resource(url: url, client_cert: client_cert, client_key: client_key, ca_file: ca_file)
            issue_request(method: :get, path: URI.parse(url).request_uri, headers: default_headers, connection: conn, process: false)
          end

          alias_method :retrieve_upstream_export, :start_upstream_export

          def update(url, client_cert, client_key, ca_file, attributes)
            conn = resource(url: url, client_cert: client_cert, client_key: client_key, ca_file: ca_file)
            issue_request(method: :put, path: URI.parse(url).request_uri, headers: default_headers, payload: attributes.to_json, connection: conn, process: false)
          end

          def regenerate_upstream_identity(url, client_cert, client_key, ca_file)
            conn = resource(url: url, client_cert: client_cert, client_key: client_key, ca_file: ca_file)
            issue_request(method: :post, path: URI.parse(url).request_uri, headers: default_headers, connection: conn, process: false)
          end

          def bind_entitlement(**pool)
            entitlements_path = join_path(path, 'entitlements') + hash_to_query(pool)
            response = self.post(entitlements_path, nil, headers: self.default_headers)
            JSON.parse(response.body)
          end
        end
      end
    end
  end
end
