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
  end
end
