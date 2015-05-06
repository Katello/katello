module Actions
  module Katello
    module Organization
      class IndexSubscriptions < Actions::Base
        middleware.use Actions::Middleware::RemoteAction

        input_format do
          param :organization_label, String
          param :provider_id
        end

        def plan(organization)
          plan_self(organization_label: organization.label,
                    provider_id: organization.redhat_provider.id
                   )
        end

        def finalize
          cp_pools = begin
                       ::Katello::Resources::Candlepin::Owner.pools(input[:organization_label])
                     rescue RestClient::ResourceNotFound
                       [] # org has been destroyed, remove its pools from ES
                     end

          if cp_pools
            # Pool objects
            pools = cp_pools.collect { |cp_pool| Katello::Pool.find_pool(cp_pool['id'], cp_pool) }

            # Limit subscriptions to just those from Red Hat provider
            subscriptions = pools.collect do |pool|
              product = Product.in_org(self.organization).where(:cp_id => pool.product_id).first
              next if product.nil?
              pool.provider_id = product.provider_id   # Set so it is saved into elastic search
              pool
            end
            subscriptions.compact!
          else
            subscriptions = []
          end

          # Index pools
          ::Katello::Pool.index_pools(subscriptions, [{term: {org: input[:organization_label]}},
                                                      {term: {provider_id: input[:provider_id]}}]
                                     )
        end
      end
    end
  end
end
