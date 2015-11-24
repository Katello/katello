require 'katello_test_helper'

module Katello
  class PoolWithQuantityTest < ActiveSupport::TestCase
    def setup
      @pool = katello_pools(:pool_one)
    end

    def test_new
      pool_with_q = PoolWithQuantities.new(@pool, [1])

      assert_equal @pool, pool_with_q.pool
      assert_equal [1], pool_with_q.quantities
    end

    def test_new_no_array
      pool_with_q = PoolWithQuantities.new(@pool, 1)

      assert_equal @pool, pool_with_q.pool
      assert_equal [1], pool_with_q.quantities
    end
  end
end
