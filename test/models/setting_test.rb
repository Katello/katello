require 'katello_test_helper'

module Katello
  class SettingTest < ActiveSupport::TestCase
    def test_default_download_policy_setting
      setting = Setting.where(:name => "default_download_policy").first
      setting.value = "invalid"
      refute setting.valid?
      setting.value = "immediate"
      assert setting.valid?
    end

    def test_recalculate_errata_status
      ForemanTasks.expects(:async_task).with(::Actions::Katello::Host::RecalculateErrataStatus)
      setting = Setting.where(:name => "errata_status_installable").first
      setting.value = !setting.value
      setting.save!
    end
  end
end
