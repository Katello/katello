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
            resource.head
          rescue RestClient::Unauthorized, RestClient::Gone
            raise ::Katello::Errors::UpstreamConsumerGone
          rescue RestClient::NotFound
            raise ::Katello::Errors::UpstreamConsumerNotFound
          end

          # Overrides the HttpResource get method to check if the upstream
          # consumer exists.
          def get(params)
            includes = params.key?(:include_only) ? "&" + included_list(params.delete(:include_only)) : ""
            JSON.parse(super(path + hash_to_query(params) + includes, self.default_headers).body)
          rescue RestClient::Gone
            raise ::Katello::Errors::UpstreamConsumerGone
          end

          def content_access
            JSON.parse(self['content_access'].get).with_indifferent_access
          rescue RestClient::NotFound
            {}
          end

          def remove_entitlement(entitlement_id)
            fail ArgumentError, "No entitlement ID given to remove." if entitlement_id.blank?

            self["entitlements/#{entitlement_id}"].delete
          rescue RestClient::NotFound
            raise ::Katello::Errors::UpstreamEntitlementGone
          end

          def get_export(url, client_cert, client_key, ca_file)
            logger.debug "Sending GET request to upstream Candlepin: #{url}"
            return resource(url: url, client_cert: client_cert, client_key: client_key, ca_file: ca_file).get
          rescue RestClient::Exception => e
            raise e
          end

          def update(url, client_cert, client_key, ca_file, attributes)
            logger.debug "Sending PUT request to upstream Candlepin: #{url} #{attributes.to_json}"
            return resource(url: url, client_cert: client_cert, client_key: client_key, ca_file: ca_file).put(attributes.to_json,
                                                                       'accept' => 'application/json',
                                                                       'accept-language' => I18n.locale,
                                                                       'content-type' => 'application/json')
          end

          def bind_entitlement(**pool)
            JSON.parse(self['entitlements'].post(nil, params: pool))
          end
        end
      end
    end
  end
end
