require 'katello_test_helper'

module Katello
  class ModuleProfileRpmTest < ActiveSupport::TestCase
    def setup
      @module_profile_tributary = katello_module_profiles(:tributary)
      @module_profile_rpm_canoe = katello_module_profile_rpms(:canoe)
    end

    def test_module_profile_relation
      assert_equal @module_profile_rpm_canoe.module_profile, @module_profile_tributary
    end
  end
end
