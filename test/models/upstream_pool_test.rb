require 'katello_test_helper'

module Katello
  class UpstreamPoolTest < ActiveSupport::TestCase
    def setup
      @organization = get_organization
      @response = mock
      @raw_pool = [{
        'id' => :pool_id,
        'activeSubscription' => :active,
        'quantity' => :quantity,
        'startDate' => :start_date,
        'endDate' => :end_date,
        'contractNumber' => :contract_number,
        'consumed' => :consumed,
        'productName' => :product_name,
        'productId' => :product_id,
        'subscriptionId' => :subscription_id
      }]
    end

    def stub_fetch_pools(response, extra_params: [], included_fields: UpstreamPool.all_fields)
      Katello::UpstreamPool.expects(:request_params)
                           .with(base_params: {},
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
      @response.expects(:to_str).returns(@raw_pool.to_json)
      @response.expects(:headers).returns({})
      stub_fetch_pools(@response)

      pools = UpstreamPool.fetch_pools({})
      pool = pools[:pools].first

      @raw_pool.first.each_value do |value|
        assert_equal value, pool[value].to_sym
      end
    end

    def test_fetch_pools_total
      @response.expects(:to_str).returns("[{}]")
      @response.expects(:headers).returns({})
      stub_fetch_pools(@response)

      pools = UpstreamPool.fetch_pools({})

      assert_equal 1, pools[:total]
    end

    def test_fetch_pools_total_with_header
      @response.expects(:to_str).returns("[]")
      @response.expects(:headers).returns(x_total_count: 4)
      stub_fetch_pools(@response)

      pools = UpstreamPool.fetch_pools({})

      assert_equal 4, pools[:total]
    end

    def test_fetch_pools_with_pool_ids
      @response.expects(:to_str).returns(@raw_pool.to_json)
      @response.expects(:headers).returns({})
      pool_ids = [[:poolid, "pool_id"]]
      stub_fetch_pools(@response, extra_params: pool_ids)

      pools = UpstreamPool.fetch_pools(
        {pool_ids: ["pool_id"] }.with_indifferent_access
      )
      assert_equal 1, pools[:total]
    end

    def test_fetch_pools_quantities_only_true
      @response.expects(:to_str).returns(@raw_pool.to_json)
      @response.expects(:headers).returns({})
      stub_fetch_pools(@response, included_fields: ["id", "quantity"])

      params = {quantities_only: true}.with_indifferent_access
      pools = UpstreamPool.fetch_pools(params)
      assert_equal 1, pools[:total]
    end

    def test_fetch_pools_quantities_only_false
      @response.expects(:to_str).returns(@raw_pool.to_json)
      @response.expects(:headers).returns({})
      stub_fetch_pools(@response, included_fields: UpstreamPool.all_fields)

      params = {quantities_only: false}.with_indifferent_access
      pools = UpstreamPool.fetch_pools(params)
      assert_equal 1, pools[:total]
    end
  end
end
