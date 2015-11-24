module Katello
  class PoolWithQuantities
    attr_accessor :pool, :quantities

    def initialize(pool = nil, quantities = [])
      @pool = pool
      @quantities = quantities
      @quantities = [@quantities] if !@quantities.nil? && !@quantities.is_a?(Array)
    end
  end
end
