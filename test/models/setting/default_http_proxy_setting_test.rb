require 'katello_test_helper'

module Katello
  class DefaultHTTPProxySettingTest < ActiveSupport::TestCase
    class TestAppController < ApplicationController
    end

    def setup
      @name = 'content_default_http_proxy'
    end

    def test_default_setting_accepts_proxy_name
      setting = Setting.where(name: @name).first
      proxy = FactoryBot.create(:http_proxy)
      setting.value = proxy.name
      assert setting.valid?
    end

    def test_collection_children_empty_when_no_proxies_defined
      children = TestAppController.helpers.send("#{@name}_collection").last[:children]
      assert_empty children
    end

    def test_collection_includes_defined_proxy
      proxy = FactoryBot.create(:http_proxy)
      children = TestAppController.helpers.send("#{@name}_collection").last[:children]
      assert_includes children, proxy.name
    end

    def test_changing_proxy_name_updates_setting
      proxy = FactoryBot.create(:http_proxy)
      setting = Setting.where(name: @name).first
      setting.update_attribute(:value, proxy.name)

      proxy.update_attribute(:name, "Some other proxy name")
      assert_equal "Some other proxy name", setting.reload.name
    end

  end
end
