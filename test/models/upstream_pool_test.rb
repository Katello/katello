require 'katello_test_helper'

module Katello
  class UpstreamPoolTest < ActiveSupport::TestCase
    def setup
      @organization = get_organization
    end

    def test_fetch_pools
      params = {}
      UpstreamPool::CP_POOL.expects(:get)
        .with(params: UpstreamPool.cp_request_params)
        .returns("[]")
      assert UpstreamPool.fetch_pools(@organization, params).first.nil?
    end
  end
end
