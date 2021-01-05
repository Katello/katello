module Katello
  class HostSubscriptionPresenter < SimpleDelegator
    attr_reader :quantity_consumed

    def initialize(pool:, entitlement:)
      @quantity_consumed = entitlement.try(:[], :quantity)
      super(pool)
    end
  end
end
