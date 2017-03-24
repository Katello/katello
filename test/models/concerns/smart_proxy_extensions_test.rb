# encoding: utf-8

require 'katello_test_helper'

module Katello
  class SmartProxyExtensionsTest < ActiveSupport::TestCase
    def setup
      @library = katello_environments(:library)
      @view = katello_content_views(:library_dev_view)
      @proxy = FactoryGirl.build(:smart_proxy, :url => 'http://fakepath.com/foo')
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

    def test_destroy_with_content_facet
      host = FactoryGirl.create(:host, :with_content, :content_view => @view,
                                          :lifecycle_environment => @library)

      host.content_facet.content_source = @proxy
      host.save!

      assert @proxy.destroy!
    end
  end
end
