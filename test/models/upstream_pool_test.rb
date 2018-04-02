require 'katello_test_helper'

module Katello
  class UpstreamPoolTest < ActiveSupport::TestCase
    def setup
      @organization = get_organization
      @response = mock
    end

    def stub_fetch_pools(response)
      Resources::Candlepin::UpstreamPool.expects(:get)
        .with(params: UpstreamPool.cp_request_params)
        .returns(response)
    end

    def test_fetch_pools
      raw_pool = [{
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
      @response.expects(:to_str).returns(raw_pool.to_json)
      @response.expects(:headers).returns({})
      stub_fetch_pools(@response)

      pools = UpstreamPool.fetch_pools({})
      pool = pools[:pools].first

      raw_pool.first.each_value do |value|
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
  end
end
