module Katello
  class PoolWithQuantities
    attr_accessor :pool, :quantities

    def initialize(pool = nil, quantities = [])
      @pool = pool
      @quantities = quantities
      @quantities = [@quantities] if !@quantities.nil? && !@quantities.is_a?(Array)
    end

    def to_hash
      {"pool_id" => pool.id, "quantities" => quantities.as_json}
    end

    def self.fetch(params)
      if params.is_a?(PoolWithQuantities)
        params
      else
        PoolWithQuantities.new(Pool.find(params["pool_id"]), params["quantities"])
      end
    end
  end
end
