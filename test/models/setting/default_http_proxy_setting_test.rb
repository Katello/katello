require 'katello_test_helper'

module Katello
  class DefaultHTTPProxySettingTest < ActiveSupport::TestCase
    def setup
      @name = 'content_default_http_proxy'
      HttpProxy.delete_all
    end

    def test_default_setting_accepts_proxy_name
      proxy = FactoryBot.create(:http_proxy)
      setting = Foreman.settings.set_user_value(@name, proxy.name)
      assert setting.valid?
    end

    def test_collection_children_empty_when_no_proxies_defined
      children = Foreman.settings.find(@name).select_values.last[:children]
      assert_empty children
    end

    def test_collection_includes_defined_proxy
      proxy = FactoryBot.create(:http_proxy)
      children = Foreman.settings.find(@name).select_values.last[:children]
      assert_equal children.first[:value], proxy.name
    end

    def test_changing_proxy_name_updates_setting
      proxy = FactoryBot.create(:http_proxy)
      Setting[@name] = proxy.name

      proxy.update_attribute(:name, "Some other proxy name")
      assert_equal "Some other proxy name", Setting[@name]
    end

    def test_proxy_name_partial_match_does_not_update_setting
      proxy = FactoryBot.create(:http_proxy, name: 'foo')
      Setting[@name] = proxy.name

      FactoryBot.create(:http_proxy, name: 'foobar')
      assert_equal proxy.name, Setting[@name]
    end

    def test_adding_first_proxy_does_not_change_setting
      assert_nil Setting[@name]

      first_proxy = FactoryBot.create(:http_proxy)
      Rails.cache.delete("setting/#{@name}")
      assert_nil Setting[@name]
      refute_equal first_proxy.name, Setting[@name]
    end

    def test_adding_new_proxy_does_not_change_setting
      proxy = FactoryBot.create(:http_proxy)
      Setting[@name] = proxy.name

      new_proxy = FactoryBot.create(:http_proxy, name: "second proxy")
      Rails.cache.delete("setting/#{@name}")
      assert_equal proxy.name, Setting[@name]
      refute_equal new_proxy.name, Setting[@name]
    end

    def test_assigning_setting_associates_all_organizations
      3.times.each { FactoryBot.create(:organization) }
      organization_count = Organization.count
      refute_equal 0, organization_count

      proxy = FactoryBot.create(:http_proxy)
      assert_equal 0, proxy.organizations.count

      Setting[@name] = proxy.name
      assert_equal organization_count, proxy.organizations.count
    end

    def test_assigning_setting_associates_all_locations
      3.times.each { FactoryBot.create(:location) }
      location_count = Location.count
      refute_equal 0, location_count

      proxy = FactoryBot.create(:http_proxy)
      assert_equal 0, proxy.locations.count

      Setting[@name] = proxy.name
      assert_equal location_count, proxy.locations.count
    end

    def test_new_organization_is_added_to_current_global_http_proxy
      proxy = FactoryBot.create(:http_proxy)
      other_proxy = FactoryBot.create(:http_proxy, name: 'another_proxy')
      organization = FactoryBot.build(:organization)

      refute_includes proxy.organizations, organization
      refute_includes other_proxy.organizations, organization

      Setting[@name] = proxy.name
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

      Setting[@name] = proxy.name
      location.save

      assert_includes proxy.reload.locations, location
      refute_includes other_proxy.reload.locations, location
    end

    def changing_default_proxy_updates_repos_using_global_proxy
      ForemanTasks.stubs(:async_task)

      proxy = FactoryBot.create(:http_proxy)
      other_proxy = FactoryBot.create(:http_proxy, name: 'another_proxy')

      Setting[@name] = proxy.name

      @no_proxy_repo = katello_repositories(:fedora_17_x86_64_acme_dev)
      @no_proxy_repo.root.update(http_proxy_policy: RootRepository::NO_DEFAULT_HTTP_PROXY)

      repo = katello_repositories(:rhel_6_x86_64)
      repo.root.update(http_proxy_policy: Katello::RootRepository::GLOBAL_DEFAULT_HTTP_PROXY)

      Setting[@name] = other_proxy.name

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
