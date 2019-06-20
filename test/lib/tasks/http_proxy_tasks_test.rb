require 'katello_test_helper'
require 'rake'

module Katello
  class UpdateContentHttpProxyTest < ActiveSupport::TestCase
    def setup
      Rake.application.rake_require 'katello/tasks/update_content_default_http_proxy'
      Rake::Task['katello:update_default_http_proxy'].reenable
      Rake::Task.define_task(:environment)
      @setting = Setting::Content.where(name: 'content_default_http_proxy').first
      assert @setting
    end

    def test_update_proxy_with_missing_proxy
      exit_code = assert_raises SystemExit do
        ARGV.concat(['--', '--name', 'foobar'])
        Rake::Task['katello:update_default_http_proxy'].invoke
      end
      assert_equal 1, exit_code.status, "Task didn't exit with expected exit code."
      refute_equal "some proxy", @setting.reload.value
    end

    def test_update_proxy_by_proxy_url_fails
      current_default_proxy = FactoryBot.create(:http_proxy)
      @setting.update_attribute(:value, current_default_proxy.name)
      proxy = FactoryBot.create(:http_proxy)
      exit_code = assert_raises SystemExit do
        ARGV.concat(['--', '-u', proxy.url])
        Rake::Task['katello:update_default_http_proxy'].invoke
      end
      assert_equal 2, exit_code.status, "Task didn't exit with expected exit code."
      assert_equal current_default_proxy.name, @setting.reload.value
    end

    def test_update_proxy_by_proxy_name_sets_default
      current_default_proxy = FactoryBot.create(:http_proxy)
      @setting.update_attribute(:value, current_default_proxy.name)
      proxy = FactoryBot.create(:http_proxy)
      assert_raises SystemExit do
        ARGV.concat(['--', '--name', proxy.name])
        Rake::Task['katello:update_default_http_proxy'].invoke
      end
      assert_equal proxy.name, @setting.reload.value
    end

    def test_update_proxy_by_proxy_short_option_name_sets_default
      current_default_proxy = FactoryBot.create(:http_proxy)
      @setting.update_attribute(:value, current_default_proxy.name)
      proxy = FactoryBot.create(:http_proxy)
      assert_raises SystemExit do
        ARGV.concat(['--', '-n', proxy.name])
        Rake::Task['katello:update_default_http_proxy'].invoke
      end
      assert_equal proxy.name, @setting.reload.value
    end

    def test_update_proxy_by_proxy_name_and_url_creates_new_proxy
      assert 0, HttpProxy.all.count

      assert_raises SystemExit do
        ARGV.concat(['--', '--name', 'new_proxy', '--url', 'http://someurl'])
        Rake::Task['katello:update_default_http_proxy'].invoke
      end

      assert_equal 1, HttpProxy.count
      assert_equal 'new_proxy', HttpProxy.last.name
      assert_equal 'http://someurl', HttpProxy.last.url
    end

    def test_update_proxy_by_proxy_name_and_url_set_default_proxy
      assert_nil @setting.value
      assert_raises SystemExit do
        ARGV.concat(['--', '--name', 'new_proxy', '--url', 'http://someurl'])
        Rake::Task['katello:update_default_http_proxy'].invoke
      end
      assert_equal 'new_proxy', @setting.reload.value
    end

    def test_proxy_list_when_no_proxies
      assert_empty HttpProxy.all.to_a
      Rake.application.invoke_task("katello:http_proxy_list")
    end

    def test_proxy_list_with_defined_proxies
      3.times { FactoryBot.create(:http_proxy) }
      Rake.application.invoke_task("katello:http_proxy_list")
    end
  end
end
