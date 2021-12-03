require 'katello_test_helper'

module Katello
  module Service
    class PoolServiceTest < ActiveSupport::TestCase
      def setup
        @pool_one = katello_pools(:pool_one)
        @pool_two = katello_pools(:pool_two)
      end

      def test_local_to_upstream_ids
        pool_ids = [@pool_one.id, @pool_two.id]
        Katello::Pool.expects(:where).with(id: pool_ids).returns([@pool_one, @pool_two])
        @pool_one.expects(:upstream_pool_id).returns('pool_one_upstream_id').twice
        @pool_two.expects(:upstream_pool_id).returns('pool_two_upstream_id').twice

        result = Katello::Candlepin::PoolService.local_to_upstream_ids(pool_ids)

        assert_equal [@pool_one.id], result['pool_one_upstream_id']
        assert_equal [@pool_two.id], result['pool_two_upstream_id']
      end

      def test_local_to_upstream_ids_no_upstream
        Katello::Pool.any_instance.expects(:upstream_pool_id).returns(nil)

        error = _ { proc { Katello::Candlepin::PoolService.local_to_upstream_ids([@pool_one.id]) } }.must_raise RuntimeError
        assert_match(/No upstream pool ID/, error.message)
      end

      def test_local_to_upstream_ids_no_fail
        pool_ids = [999_999, 999_998]
        result = Katello::Candlepin::PoolService.local_to_upstream_ids(pool_ids, fail_on_not_found: false)
        assert_equal result, {}
      end

      def test_map_upstream_pools_to_local
        pools = [{ "id" => @pool_one.upstream_pool_id }]

        result = Katello::Candlepin::PoolService.map_upstream_pools_to_local(pools)
        assert_equal result, "#{@pool_one.upstream_pool_id}" => [@pool_one.id]
      end
    end
  end
end
