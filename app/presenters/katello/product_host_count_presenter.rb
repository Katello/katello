module Katello
  class ProductHostCountPresenter < SimpleDelegator
    attr_reader :product_host_count

    def initialize(pool)
      @product_host_count = pool.product_host_count
      super(pool)
    end
  end
end
