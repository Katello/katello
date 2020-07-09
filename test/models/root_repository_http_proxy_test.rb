require File.expand_path("repository_base", File.dirname(__FILE__))
require 'katello_test_helper'

module Katello
  class RootRepositoryHttpProxyTest < RepositoryTestBase
    let(:proxy) { FactoryBot.create(:http_proxy) }
    let(:other_proxy) { FactoryBot.create(:http_proxy, url: 'http://someotherurl') }

    def setup
      super
      FactoryBot.create(:smart_proxy, :default_smart_proxy)
      User.current = @admin
      @root = build(:katello_root_repository,
                    :product => katello_products(:fedora)
                   )
      Setting['content_default_http_proxy'] = proxy.name
    end

    def test_default_http_proxy_when_there_is_no_global_default_set
      assert Katello::RootRepository::NO_DEFAULT_HTTP_PROXY, @root.http_proxy_policy
    end

    def test_http_proxy_is_global_proxy_when_global_default_exists_and_policy_is_global
      @root.update_attribute(:http_proxy_policy, Katello::RootRepository::GLOBAL_DEFAULT_HTTP_PROXY)
      assert_equal proxy, @root.http_proxy
    end

    def test_http_proxy_is_global_proxy_after_setting_http_proxy
      @root.http_proxy = other_proxy
      @root.save
      @root.update_attribute(:http_proxy_policy, Katello::RootRepository::GLOBAL_DEFAULT_HTTP_PROXY)
      assert_equal proxy, @root.http_proxy
    end

    def test_http_proxy_is_selected_proxy_when_global_proxy_exists
      @root.http_proxy = other_proxy
      @root.save
      @root.update_attribute(:http_proxy_policy, Katello::RootRepository::USE_SELECTED_HTTP_PROXY)
      assert_equal other_proxy, @root.reload.http_proxy
    end
  end

  class HttpProxyScopeTest < ActiveSupport::TestCase
    let(:default_proxy) { FactoryBot.create(:http_proxy, name: "global default") }

    def setup
      Setting['content_default_http_proxy'] = default_proxy.name

      @other_proxy = FactoryBot.create(:http_proxy)
      @another_proxy = FactoryBot.create(:http_proxy)

      @repo1 = FactoryBot.create(:katello_repository, :with_product)
      @repo1.root.update(http_proxy_policy: RootRepository::GLOBAL_DEFAULT_HTTP_PROXY)

      @repo2 = FactoryBot.create(:katello_repository, :with_product)
      @repo2.root.update(http_proxy_policy: RootRepository::NO_DEFAULT_HTTP_PROXY,
                    http_proxy_id: @other_proxy.id)

      @repo3 = FactoryBot.create(:katello_repository, :with_product)
      @repo3.root.update(http_proxy_policy: RootRepository::USE_SELECTED_HTTP_PROXY,
                    http_proxy_id: @another_proxy.id)

      @repo4 = FactoryBot.create(:katello_repository, :with_product)
      @repo4.root.update(http_proxy_policy: RootRepository::GLOBAL_DEFAULT_HTTP_PROXY,
                      http_proxy_id: @another_proxy.id)
    end

    def test_global_repositories
      global_proxies = RootRepository.with_global_proxy
      assert_includes global_proxies, @repo1.root
      assert_includes global_proxies, @repo4.root
      refute_includes global_proxies, @repo2.root
      refute_includes global_proxies, @repo3.root
    end

    def test_no_proxy_repositories
      no_proxies = RootRepository.with_no_proxy
      assert_includes no_proxies, @repo2.root
      refute_includes no_proxies, @repo1.root
      refute_includes no_proxies, @repo3.root
      refute_includes no_proxies, @repo4.root
    end

    def test_selected_proxy_repositories
      selected_proxies = RootRepository.with_selected_proxy(@another_proxy.id)
      assert_includes selected_proxies, @repo3.root
      refute_includes selected_proxies, @repo1.root
      refute_includes selected_proxies, @repo2.root
      refute_includes selected_proxies, @repo4.root
    end
  end
end
