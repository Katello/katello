require 'katello_test_helper'
require 'rake'

module Katello
  class UpdateContentHttpProxyTest < ActiveSupport::TestCase
    def setup
      Rake.application.rake_require 'katello/tasks/update_content_default_http_proxy'
      Rake::Task['katello:update_default_http_proxy'].reenable
      Rake::Task.define_task(:environment)
      HttpProxy.delete_all

      ::Setting.any_instance.stubs(:update_global_proxies)
      ::HttpProxy.any_instance.stubs(:update_default_proxy_setting)
      ::HttpProxy.any_instance.stubs(:update_repository_proxy_details)
    end

    def test_without_name_fails
      assert_equal 0, HttpProxy.all.count
      exit_code = assert_raises SystemExit do
        ARGV.concat(['--', '-u', 'http://someurl'])
        Rake::Task['katello:update_default_http_proxy'].invoke
      end
      assert_equal 2, exit_code.status, "Task didn't exit with expected exit code."
      assert_equal 0, HttpProxy.all.count
    end

    def test_without_url_fails
      assert_equal 0, HttpProxy.all.count
      exit_code = assert_raises SystemExit do
        ARGV.concat(['--', '-n', 'a new proxy'])
        Rake::Task['katello:update_default_http_proxy'].invoke
      end
      assert_equal 2, exit_code.status, "Task didn't exit with expected exit code."
      assert_equal 0, HttpProxy.all.count
    end

    def test_update_proxy_sets_default
      current_default_proxy = FactoryBot.create(:http_proxy)
      Setting['content_default_http_proxy'] = current_default_proxy.name
      proxy = FactoryBot.create(:http_proxy)
      assert_raises SystemExit do
        ARGV.concat(['--', '--name', proxy.name, '--url', 'http://someurl'])
        Rake::Task['katello:update_default_http_proxy'].invoke
      end
      assert_equal proxy.name, Setting['content_default_http_proxy']
    end

    def test_update_proxy_updates_url
      proxy = FactoryBot.create(:http_proxy, url: 'http://someurl')
      assert_raises SystemExit do
        ARGV.concat(['--', '--name', proxy.name, '--url', 'http://someotherurl'])
        Rake::Task['katello:update_default_http_proxy'].invoke
      end
      assert_equal 'http://someotherurl', proxy.reload.url
    end

    def test_update_proxy_updates_username
      proxy = FactoryBot.create(:http_proxy, url: 'http://someurl')
      assert_raises SystemExit do
        ARGV.concat(['--', '--name', proxy.name, '--url', 'http://someotherurl', '--user', 'admin'])
        Rake::Task['katello:update_default_http_proxy'].invoke
      end
      assert_equal 'admin', proxy.reload.username
    end

    def test_creates_with_port
      name = 'foo'
      assert_raises SystemExit do
        ARGV.concat(['--', '--name', name, '--url', 'http://someurl', '--user', 'admin', '--port', '8080'])
        Rake::Task['katello:update_default_http_proxy'].invoke
      end
      assert HttpProxy.find_by(name: name)
      assert_equal 'http://someurl:8080', HttpProxy.find_by(name: name).url
    end

    def test_update_proxy_updates_password
      proxy = FactoryBot.create(:http_proxy, url: 'http://someurl')
      assert_raises SystemExit do
        ARGV.concat(['--', '--name', proxy.name, '--url', 'http://someotherurl', '--password', 'redhat'])
        Rake::Task['katello:update_default_http_proxy'].invoke
      end
      assert_equal 'redhat', proxy.reload.password
    end

    def test_update_proxy_by_short_option_name_sets_default
      current_default_proxy = FactoryBot.create(:http_proxy)
      Setting['content_default_http_proxy'] = current_default_proxy.name
      proxy = FactoryBot.create(:http_proxy)
      assert_raises SystemExit do
        ARGV.concat(['--', '-n', proxy.name, '--url', proxy.url])
        Rake::Task['katello:update_default_http_proxy'].invoke
      end
      assert_equal proxy.name, Setting['content_default_http_proxy']
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

    def test_update_proxy_by_proxy_name_and_short_url_option_creates_new_proxy
      assert 0, HttpProxy.all.count

      assert_raises SystemExit do
        ARGV.concat(['--', '--name', 'new_proxy', '-u', 'http://someurl'])
        Rake::Task['katello:update_default_http_proxy'].invoke
      end

      assert_equal 1, HttpProxy.count
      assert_equal 'new_proxy', HttpProxy.last.name
      assert_equal 'http://someurl', HttpProxy.last.url
    end

    def test_password_is_not_displayed_when_part_of_url
      proxy = FactoryBot.build(:http_proxy, url: 'http://admin:redhat@http://someurl.com:8888')
      refute_match(/redhat/, proxy.name_and_url, "Name and url included password in displayed string.")
    end

    def test_password_is_not_display_when_specified_in_model
      proxy = FactoryBot.build(:http_proxy, url: 'http://someurl.com:8888', password: 'redhat')
      refute_match(/redhat/, proxy.name_and_url, "Name and url included password in displayed string.")
    end

    def test_password_in_url_is_removed
      proxy = FactoryBot.build(:http_proxy)
      assert_raises SystemExit do
        ARGV.concat(['--', '--name', proxy.name, '--url', 'http://admin:redhat@someotherurl'])
        Rake::Task['katello:update_default_http_proxy'].invoke
      end
      refute_match(/redhat/, HttpProxy.first.url)
    end

    def test_username_in_url_is_removed
      proxy = FactoryBot.build(:http_proxy)
      assert_raises SystemExit do
        ARGV.concat(['--', '--name', proxy.name, '--url', 'http://admin:redhat@someotherurl'])
        Rake::Task['katello:update_default_http_proxy'].invoke
      end
      refute_match(/admin/, HttpProxy.first.url)
    end
  end
end
