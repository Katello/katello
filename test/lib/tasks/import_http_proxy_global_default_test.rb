require 'katello_test_helper'
require 'rake'

module Katello
  class ImportHTTPProxyGlobalDefaultTest < ActiveSupport::TestCase
    def setup
      Rake.application.rake_require 'katello/tasks/import_http_proxy_global_default'
      @task_name = 'katello:import_default_http_proxy'
      Rake::Task[@task_name].reenable
      Rake::Task.define_task(:environment)

      @setting = ::Setting.find_by(name: 'content_default_http_proxy')
    end

    def test_answers_has_no_katello_secion_exits_with_error
      answers = {}

      assert_raises SystemExit do
        provision_global_default_http_proxy(answers)
      end

      assert_nil @setting.value
    end

    def test_answers_has_no_katello_proxy_url_settings_exits_with_error
      answers = {
        'katello' => {
          'proxy_somethingsomething' => 'fgoo'
        }
      }

      assert_raises SystemExit do
        provision_global_default_http_proxy(answers)
      end

      assert_nil @setting.value
    end

    def test_answers_no_proxy_name_creates_http_proxy_with_default_name
      answers = {
        'katello' => {
          'proxy_url' => 'http://foo.org' }}

      provision_global_default_http_proxy(answers)

      refute_nil HttpProxy.default_global_content_proxy
      assert_equal 'foo.org', @setting.reload.value
    end

    def test_proxy_port_specified_in_proxy_url
      answers = {
        'katello' => {
          'proxy_url' => 'http://foo.org:8888' }}

      provision_global_default_http_proxy(answers)

      assert_equal 8888, URI(HttpProxy.default_global_content_proxy.url).port
    end

    def test_proxy_user_specified_in_proxy_url
      answers = {
        'katello' => {
          'proxy_url' => 'http://admin:redhat@foo.org' }}

      provision_global_default_http_proxy(answers)

      assert_equal 'admin', HttpProxy.default_global_content_proxy.username
    end

    def test_proxy_user_specified_as_proxy_username
      answers = {
        'katello' => {
          'proxy_url' => 'http://joe@foo.org',
          'proxy_username' => 'admin'}}

      provision_global_default_http_proxy(answers)

      assert_equal 'admin', HttpProxy.default_global_content_proxy.username
    end

    def test_proxy_password_specified_in_proxy_url
      answers = {
        'katello' => {
          'proxy_url' => 'http://admin:redhat@foo.org' }}

      provision_global_default_http_proxy(answers)

      assert_equal 'redhat', HttpProxy.default_global_content_proxy.password
    end

    def test_proxy_password_specified_as_proxy_password
      answers = {
        'katello' => {
          'proxy_url' => 'http://joe:sekret@foo.org',
          'proxy_password' => 'redhat'}}

      provision_global_default_http_proxy(answers)

      assert_equal 'redhat', HttpProxy.default_global_content_proxy.password
    end

    def test_specifying_proxy_details_duplicates_exiting_http_proxy
      answers = {
        'katello' => {
          'proxy_url' => 'http://joe:sekret@foo.org:8888' }}

      FactoryBot.create(:http_proxy, name: 'foo.org')

      provision_global_default_http_proxy(answers)

      assert_equal 'foo.org (global)', HttpProxy.default_global_content_proxy.name
    end
  end
end
