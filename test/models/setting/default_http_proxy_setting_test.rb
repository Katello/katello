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
      assert_equal "Some other proxy name", Setting.where(name: @name).first.value
    end

    def test_proxy_name_partial_match_does_not_update_setting
      proxy = FactoryBot.create(:http_proxy, name: 'foo')
      setting = Setting.where(name: @name).first
      setting.update_attribute(:value, proxy.name)

      FactoryBot.create(:http_proxy, name: 'foobar')
      assert_equal proxy.name, Setting.where(name: @name).first.value
    end

    def test_adding_first_proxy_does_not_change_setting
      setting = Setting.where(name: @name).first
      assert_nil setting.value

      first_proxy = FactoryBot.create(:http_proxy)
      assert_nil setting.reload.value
      refute_equal first_proxy.name, setting.reload.value
    end

    def test_adding_new_proxy_does_not_change_setting
      proxy = FactoryBot.create(:http_proxy)
      setting = Setting.where(name: @name).first
      setting.update_attribute(:value, proxy.name)

      new_proxy = FactoryBot.create(:http_proxy, name: "second proxy")
      assert_equal proxy.name, setting.reload.value
      refute_equal new_proxy.name, setting.reload.value
    end
  end
end
