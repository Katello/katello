module Katello
  class HostSubscriptionsPresenter
    def initialize(host)
      @pools = host.subscription_facet.pools.group_by(&:cp_id)
      @entitlements = host.subscription_facet.candlepin_consumer.entitlements if @pools.any?
      @entitlements ||= []
    end

    def subscriptions
      @entitlements.map do |e|
        HostSubscriptionPresenter.new(pool: pool_for_entitlement(e), entitlement: e)
      end
    end

    private

    def pool_for_entitlement(entitlement)
      pool_cp_id = entitlement['pool']['id']
      @pools[pool_cp_id]&.first
    end
  end
end
