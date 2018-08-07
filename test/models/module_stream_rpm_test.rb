require 'katello_test_helper'

module Katello
  class ModuleStreamRpmTest < ActiveSupport::TestCase
    def setup
      @module_stream_river = katello_module_streams(:river)
      @module_stream_rpm_boat = katello_module_stream_rpms(:boat)
    end

    def test_module_stream_relation
      assert_equal @module_stream_rpm_boat.module_stream, @module_stream_river
    end
  end
end
