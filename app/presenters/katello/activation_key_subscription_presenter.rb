module Katello
  class ActivationKeySubscriptionPresenter
    attr_accessor :subscription

    def initialize(subscription)
      @subscription = Katello::Pool.find_by(:cp_id => subscription["id"])
      @subscription["quantity_attached"] = subscription.try(:[], :amount)
    end
  end
end
