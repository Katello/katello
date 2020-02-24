require 'katello_test_helper'

module Katello
  class DefaultHTTPProxySettingTest < ActiveSupport::TestCase
    class TestAppController < ApplicationController
    end

    def setup
      @name = 'content_default_http_proxy'
      FactoryBot.create(:smart_proxy, :default_smart_proxy)

      HttpProxy.delete_all
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

    def test_assigning_setting_associates_all_organizations
      3.times.each { FactoryBot.create(:organization) }
      organization_count = Organization.count
      refute_equal 0, organization_count

      proxy = FactoryBot.create(:http_proxy)
      assert_equal 0, proxy.organizations.count

      setting = Setting.where(name: @name).first
      setting.update_attribute(:value, proxy.name)
      assert_equal organization_count, proxy.organizations.count
    end

    def test_assigning_setting_associates_all_locations
      3.times.each { FactoryBot.create(:location) }
      location_count = Location.count
      refute_equal 0, location_count

      proxy = FactoryBot.create(:http_proxy)
      assert_equal 0, proxy.locations.count

      setting = Setting.where(name: @name).first
      setting.update_attribute(:value, proxy.name)
      assert_equal location_count, proxy.locations.count
    end

    def test_new_organization_is_added_to_current_global_http_proxy
      proxy = FactoryBot.create(:http_proxy)
      other_proxy = FactoryBot.create(:http_proxy, name: 'another_proxy')
      organization = FactoryBot.build(:organization)

      refute_includes proxy.organizations, organization
      refute_includes other_proxy.organizations, organization

      setting = Setting.where(name: @name).first
      setting.update_attribute(:value, proxy.name)
      organization.save

      assert_includes proxy.reload.organizations, organization
      refute_includes other_proxy.reload.organizations, organization
    end

    def test_new_location_is_added_to_current_global_http_proxy
      proxy = FactoryBot.create(:http_proxy)
      other_proxy = FactoryBot.create(:http_proxy, name: 'another_proxy')
      location = FactoryBot.build(:location)

      refute_includes proxy.locations, location
      refute_includes other_proxy.locations, location

      setting = Setting.where(name: @name).first
      setting.update_attribute(:value, proxy.name)
      location.save

      assert_includes proxy.reload.locations, location
      refute_includes other_proxy.reload.locations, location
    end

    def changing_default_proxy_updates_repos_using_global_proxy
      ForemanTasks.stubs(:async_task)

      proxy = FactoryBot.create(:http_proxy)
      other_proxy = FactoryBot.create(:http_proxy, name: 'another_proxy')

      setting = Setting.where(name: @name).first
      setting.update_attribute(:value, proxy.name)

      @no_proxy_repo = katello_repositories(:fedora_17_x86_64_acme_dev)
      @no_proxy_repo.root.update(http_proxy_policy: RootRepository::NO_DEFAULT_HTTP_PROXY)

      repo = katello_repositories(:rhel_6_x86_64)
      repo.root.update(http_proxy_policy: Katello::RootRepository::GLOBAL_DEFAULT_HTTP_PROXY)

      setting = Setting.where(name: @name).first
      setting.update_attribute(:value, other_proxy.name)

      ForemanTasks.expects(:async_task).with(
        ::Actions::BulkAction,
        ::Actions::Katello::Repository::UpdateHttpProxyDetails,
        [repo])

      ForemanTasks.expects(:async_task).with(
        ::Actions::BulkAction,
        ::Actions::Katello::Repository::UpdateHttpProxyDetails,
        [@no_proxy_repo]).never
    end
  end
end
