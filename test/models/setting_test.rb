require 'katello_test_helper'

module Katello
  class SettingTest < ActiveSupport::TestCase
    def test_default_download_policy_setting
      setting = Foreman.settings.set_user_value('default_download_policy', 'invalid')
      refute setting.valid?
      setting.value = "immediate"
      assert setting.valid?
    end

    def test_foreman_proxy_content_auto_sync_setting
      skip 'needs setting definde through DSL and its static typing to work properly'
      setting = Foreman.settings.set_user_value('foreman_proxy_content_auto_sync', 'invalid')
      refute setting.valid?
      setting.value = true
      assert setting.valid?
    end

    def test_recalculate_errata_status
      ForemanTasks.expects(:async_task).with(::Actions::Katello::Host::RecalculateErrataStatus)
      Setting['errata_status_installable'] = !Setting['errata_status_installable']
    end
  end
end
