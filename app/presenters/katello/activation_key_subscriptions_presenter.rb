module Katello
  class ActivationKeySubscriptionsPresenter < SimpleDelegator
    attr_reader :quantity_attached

    def initialize(pool, key_pools)
      @quantity_attached ||= key_pools.find { |sub| sub['id'] == pool.cp_id }.try(:[], :amount)
      super(pool)
    end
  end
end
