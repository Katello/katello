require 'katello_test_helper'

module Katello
  class SettingTest < ActiveSupport::TestCase
    def test_default_download_policy_setting
      setting = Setting.where(:name => 'default_download_policy').first
      setting.value = "invalid"
      refute setting.valid?
      setting.value = "immediate"
      assert setting.valid?
    end

    def test_foreman_proxy_content_auto_sync_setting
      setting = Setting.where(:name => 'foreman_proxy_content_auto_sync').first
      setting.value = "invalid"
      refute setting.valid?
      setting.value = true
      assert setting.valid?
    end

    def test_cdn_ssl_setting
      setting = Setting.where(:name => 'cdn_ssl_version').first

      setting.value = nil
      assert setting.valid?

      setting.value = 'SSLv23'
      assert setting.valid?
    end

    def test_recalculate_errata_status
      ForemanTasks.expects(:async_task).with(::Actions::Katello::Host::RecalculateErrataStatus)
      Setting['errata_status_installable'] = !Setting['errata_status_installable']
    end
  end
end
