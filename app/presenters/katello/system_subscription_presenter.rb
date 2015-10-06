module Katello
  class SystemSubscriptionPresenter
    attr_accessor :subscription

    def initialize(entitlement)
      @subscription = Katello::Pool.find_by_cp_id(entitlement["pool"]["id"])
      @subscription["quantity_attached"] = entitlement.try(:[], :quantity)
    end
  end
end
