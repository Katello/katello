#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.


module ConsumersControllerLogic

  # Consumed subscriptions
  # Note: Finding the provider is necessary for cross-linking in the UI
  def consumed_subscriptions(consumer)
    consumed = consumer.consumed_entitlements.collect do |entitlement|
      pool = ::Pool.find_pool(entitlement.poolId)
      product = Product.where(:cp_id => pool.product_id).all.select do |p|
        !Provider.where(:id => p.provider_id, :organization_id => current_organization.id).first.nil?
      end
      next if product.empty?

      entitlement.provider_id = product[0].provider_id
      entitlement
    end

    return consumed
  end

  # Available subscriptions
  # Note: Finding the provider is necessary for cross-linking in the UI
  def available_subscriptions(cp_pools)
    if cp_pools
      pools = cp_pools.collect{|cp_pool| ::Pool.find_pool(cp_pool['id'], cp_pool)}

      subscriptions = pools.collect do |pool|
        product = Product.where(:cp_id => pool.product_id).all.select do |p|
          !Provider.where(:id => p.provider_id, :organization_id => current_organization.id).first.nil?
        end
        next if product.empty?

        pool.provider_id = product[0].provider_id
        pool
      end.compact
      subscriptions = [] if subscriptions.nil?
    else
      subscriptions = []
    end

    return subscriptions
  end

end
