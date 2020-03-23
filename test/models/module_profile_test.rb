require 'katello_test_helper'

module Katello
  class ModuleProfileTest < ActiveSupport::TestCase
    def setup
      @module_stream_river = katello_module_streams(:river)
      @module_profile_tributary = katello_module_profiles(:tributary)
      @module_profile_rpm_canoe = katello_module_profile_rpms(:canoe)
    end

    def test_module_stream_relation
      assert_equal @module_profile_tributary.module_stream, @module_stream_river
    end

    def test_rpms_relation
      assert_includes @module_profile_tributary.rpms, @module_profile_rpm_canoe
    end
  end
end
