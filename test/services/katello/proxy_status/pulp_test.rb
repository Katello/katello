require 'katello_test_helper'

module Katello
  module ProxyStatus
    class PulpTest < ActiveSupport::TestCase
      setup do
        @proxy = FactoryGirl.build_stubbed(:pulp_capsule)
      end

      test "should get cache_key" do
        pulp_status = Katello::ProxyStatus::Pulp.new @proxy
        assert_equal "proxy_#{@proxy.id}/pulp", pulp_status.cache_key
      end

      test "should return pulp status" do
        ProxyAPI::Pulp.any_instance.stubs(:status).returns('version 2')
        Katello::ProxyStatus::Pulp.new(@proxy).pulp_status
        assert_equal('version 2', Rails.cache.fetch("proxy_#{@proxy.id}/pulp"))
      end
    end
  end
end
