require 'katello_test_helper'
require 'support/pulp/repository_support'

module Katello
  module Services
    class RepositoryMergeProxyOptionsTest < ActiveSupport::TestCase
      include RepositorySupport

      def setup
        @master = FactoryBot.create(:smart_proxy, :default_smart_proxy)
        User.current = users(:admin)

        @default_proxy = FactoryBot.create(:http_proxy, name: 'best proxy')
        Setting.find_by(name: 'content_default_http_proxy').update(
          value: @default_proxy.name)
        @repo = katello_repositories(:fedora_17_x86_64)
        @pulp_repo = Katello::Pulp::Repository.new(@repo, @master)
      end

      def test_no_options_merged_if_no_default_proxy_and_no_http_proxy_set
        @repo.root.update_attribute(:http_proxy_policy, RootRepository::NO_DEFAULT_HTTP_PROXY)
        assert_nil @repo.root.reload.http_proxy
        assert_equal '', @pulp_repo.proxy_options[:proxy_host]
        assert_nil @pulp_repo.proxy_options[:proxy_port]
        assert_equal '', @pulp_repo.proxy_options[:proxy_username]
        assert_equal '', @pulp_repo.proxy_options[:proxy_password]
      end

      def test_no_options_merged_if_no_default_proxy_and_http_proxy_exists
        proxy = FactoryBot.create(:http_proxy)
        @repo.root.update(http_proxy_policy: RootRepository::NO_DEFAULT_HTTP_PROXY,
                          http_proxy: proxy)
        assert @repo.root.http_proxy_id
        assert_equal '', @pulp_repo.proxy_options[:proxy_host]
        assert_nil @pulp_repo.proxy_options[:proxy_port]
        assert_equal '', @pulp_repo.proxy_options[:proxy_username]
        assert_equal '', @pulp_repo.proxy_options[:proxy_password]
      end

      def test_no_options_merged_if_global_default_proxy_and_http_proxy_exists
        another_proxy = FactoryBot.create(:http_proxy)
        @repo.root.update(http_proxy_policy: RootRepository::GLOBAL_DEFAULT_HTTP_PROXY,
                          http_proxy: another_proxy)
        assert @repo.root.http_proxy_id
        uri = URI(@default_proxy.url)
        expected_options = {
          proxy_host: uri.scheme + '://' + uri.host,
          proxy_port: uri.port,
          proxy_username: @default_proxy.username,
          proxy_password: @default_proxy.password
        }
        assert_equal expected_options, @pulp_repo.proxy_options
      end

      def test_no_options_merged_if_global_default_proxy_an_no_proxy_set
        @repo.root.update(http_proxy_policy: RootRepository::GLOBAL_DEFAULT_HTTP_PROXY)
        assert_nil @repo.root.http_proxy_id
        uri = URI(@default_proxy.url)
        expected_options = {
          proxy_host: uri.scheme + '://' + uri.host,
          proxy_port: uri.port,
          proxy_username: @default_proxy.username,
          proxy_password: @default_proxy.password
        }
        assert_equal expected_options, @pulp_repo.proxy_options
      end

      def test_no_options_merged_if_selected_proxy_and_proxy_set
        another_proxy = FactoryBot.create(:http_proxy)
        @repo.root.update(http_proxy_policy: RootRepository::USE_SELECTED_HTTP_PROXY,
                          http_proxy: another_proxy)
        assert @repo.root.http_proxy_id
        uri = URI(another_proxy.url)
        expected_options = {
          proxy_host: uri.scheme + '://' + uri.host,
          proxy_port: uri.port,
          proxy_username: another_proxy.username,
          proxy_password: another_proxy.password
        }
        assert_equal expected_options, @pulp_repo.proxy_options
      end
    end
  end
end
