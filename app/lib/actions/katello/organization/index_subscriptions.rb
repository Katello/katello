#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

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
            pools = cp_pools.collect{|cp_pool| Katello::Pool.find_pool(cp_pool['id'], cp_pool)}

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
