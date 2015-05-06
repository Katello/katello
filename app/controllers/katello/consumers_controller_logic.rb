module Katello
  module ConsumersControllerLogic
    # Consumed subscriptions
    # Note: Finding the provider is necessary for cross-linking in the UI
    def consumed_subscriptions(consumer)
      consumed = consumer.consumed_entitlements.collect do |entitlement|
        pool = Katello::Pool.find_pool(entitlement.poolId)
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
    def available_subscriptions(cp_pools, organization = current_organization)
      if cp_pools
        pools = cp_pools.collect { |cp_pool| ::Katello::Pool.find_pool(cp_pool['id'], cp_pool) }

        subscriptions = pools.collect do |pool|
          product = Product.where(:cp_id => pool.product_id).all.select do |p|
            !Provider.where(:id => p.provider_id, :organization_id => organization.id).first.nil?
          end
          next if product.empty?

          pool.provider_id = product[0].provider_id
          pool
        end
        subscriptions.compact!
      else
        subscriptions = []
      end

      return subscriptions
    end
  end
end
