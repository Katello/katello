require 'katello_test_helper'

module Katello
  class UpstreamPoolTest < ActiveSupport::TestCase
    def setup
      @organization = get_organization
      @raw_pool = [{
        'id' => :id,
        'activeSubscription' => :active,
        'quantity' => :quantity,
        'startDate' => :start_date,
        'endDate' => :end_date,
        'contractNumber' => :contract_number,
        'consumed' => :consumed,
        'productName' => :product_name,
        'productId' => :product_id,
        'subscriptionId' => :subscription_id,
      }]
      @response = stub(to_str: @raw_pool.to_json, headers: {})
    end

    def stub_fetch_pools(response, base_params: {}, extra_params: [], included_fields: UpstreamPool.all_fields)
      base_params = base_params.merge(:sort_by => 'Product.name', :order => "asc")
      Katello::UpstreamPool.expects(:request_params)
                           .with(base_params: base_params,
                                 extra_params: extra_params,
                                 included_fields: included_fields)

      Resources::Candlepin::UpstreamPool.expects(:get).returns(response)
    end

    def test_request_params
      input = [[:bacon, "jam"],
               [:tomato, "sandwich"],
               [:tomato, "salad"],
               [:include, "mayo"]]

      RestClient::ParamsArray.expects(:new).with(input)

      Katello::UpstreamPool.request_params(
        base_params: {bacon: "jam"},
        extra_params: [[:tomato, "sandwich"], [:tomato, "salad"]],
        included_fields: ["mayo"]
      )
    end

    def test_fetch_pools
      stub_fetch_pools(@response)

      pools = UpstreamPool.fetch_pools({})
      pool = pools[:pools].first

      @raw_pool.first.each_value do |value|
        assert_equal value, pool[value].to_sym
      end

      assert_equal 1, pools[:total]
      assert_equal 1, pools[:subtotal]
    end

    def test_fetch_pools_total_with_header
      response = stub(to_str: '[]', headers: {x_total_count: 4})
      stub_fetch_pools(response)

      pools = UpstreamPool.fetch_pools({})

      assert_equal 4, pools[:total]
    end

    def test_fetch_pools_with_pool_ids
      expected = :local_pool_id
      pool_id_map = {'id' => [expected]}
      Katello::Candlepin::PoolService.expects(:local_to_upstream_ids).returns(pool_id_map)
      stub_fetch_pools(@response, extra_params: [[:poolid, 'id']])

      pools = UpstreamPool.fetch_pools(pool_ids: [expected])

      assert_equal [expected], pools[:pools].first.local_pool_ids
    end

    def test_fetch_pools_attachable
      stub_fetch_pools(@response, base_params: {consumer: :foo_id})
      Resources::Candlepin::UpstreamPool.expects(:upstream_consumer_id).returns(:foo_id)

      params = {attachable: true}
      pools = UpstreamPool.fetch_pools(params)

      assert_equal 1, pools[:total]
    end

    def test_fetch_pools_quantities_only_true
      stub_fetch_pools(@response, included_fields: ["id", "quantity"])

      params = {quantities_only: true}
      pools = UpstreamPool.fetch_pools(params)

      assert_equal 1, pools[:total]
    end

    def test_fetch_pools_quantities_only_false
      stub_fetch_pools(@response, included_fields: UpstreamPool.all_fields)

      params = {quantities_only: false}
      pools = UpstreamPool.fetch_pools(params)

      assert_equal 1, pools[:total]
    end

    def test_available
      upstream_pool = Katello::UpstreamPool.new(quantity: -1, consumed: 23)
      assert_equal(-1, upstream_pool.available)

      upstream_pool = Katello::UpstreamPool.new(quantity: 20, consumed: 12)
      assert_equal 8, upstream_pool.available

      upstream_pool = Katello::UpstreamPool.new(quantity: 1, consumed: nil)
      assert_equal 0, upstream_pool.available
    end
  end
end
