# encoding: utf-8

require 'katello_test_helper'

module Katello
  class SmartProxyExtensionsTest < ActiveSupport::TestCase
    def setup
      @proxy = SmartProxy.new(:name => :foo, :url => 'http://fakepath.com/foo')
      ::SmartProxy.any_instance.stubs(:associate_features)
    end

    def test_sets_default_download_policy
      Setting[:default_proxy_download_policy] = 'background'
      @proxy.save!

      assert_equal Setting[:default_proxy_download_policy], @proxy.download_policy
    end

    def test_save_with_download_policy
      @proxy.download_policy = 'background'
      @proxy.save!

      assert_equal 'background', @proxy.reload.download_policy
    end
  end
end
