module Katello
  module Resources
    module Candlepin
      class Subscription < CandlepinResource
        class << self
          def destroy(subscription_id)
            fail ArgumentError, "subscription id has to be specified" unless subscription_id
            self.delete(path(subscription_id), self.default_headers).code.to_i
          end

          def get(id = nil)
            content_json = super(path(id), self.default_headers).body
            JSON.parse(content_json)
          end

          def get_for_owner(owner_key, included = [])
            content_json = Candlepin::CandlepinResource.get(
              "/candlepin/owners/#{owner_key}/subscriptions?#{included_list(included)}",
              self.default_headers
            ).body
            JSON.parse(content_json)
          end

          def path(id = nil)
            "/candlepin/subscriptions/#{id}"
          end
        end
      end
    end
  end
end
