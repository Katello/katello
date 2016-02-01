module Katello
  class HostSubscriptionPresenter < SimpleDelegator
    attr_accessor :quantity_consumed

    def initialize(entitlement)
      @subscription = Katello::Pool.find_by(:cp_id => entitlement['pool']['id'])
      @quantity_consumed = entitlement.try(:[], :quantity)
      super(@subscription)
    end
  end
end
