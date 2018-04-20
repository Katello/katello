require 'katello_test_helper'

module Katello
  module Service
    class PoolServiceTest < ActiveSupport::TestCase
      def setup
        @pool_one = katello_pools(:pool_one)
        @pool_two = katello_pools(:pool_two)
      end

      def test_local_to_upstream_ids
        Katello::Pool.expects(:find).returns([@pool_one, @pool_two])
        @pool_one.expects(:upstream_pool_id).returns('pool_one_upstream_id').twice
        @pool_two.expects(:upstream_pool_id).returns('pool_two_upstream_id').twice

        result = Katello::Candlepin::PoolService.local_to_upstream_ids([@pool_two.id, @pool_two.id])

        assert_equal [@pool_one.id], result['pool_one_upstream_id']
        assert_equal [@pool_two.id], result['pool_two_upstream_id']
      end

      def test_local_to_upstream_ids_no_upstream
        Katello::Pool.any_instance.expects(:upstream_pool_id).returns(nil)

        error = proc { Katello::Candlepin::PoolService.local_to_upstream_ids([@pool_one.id]) }.must_raise RuntimeError
        error.message.must_match(/No upstream pool ID/)
      end
    end
  end
end
