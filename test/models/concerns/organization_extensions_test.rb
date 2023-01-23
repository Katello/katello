# encoding: utf-8

require 'katello_test_helper'

module Katello
  class OrganizationExtensionsTest < ActiveSupport::TestCase
    def setup
      User.current = User.find(users(:admin).id)
      set_default_location
      @org = get_organization(:empty_organization)
    end

    def test_active_pools_count
      pools_count = @org.active_pools_count
      assert_equal pools_count, 3

      @org.pools.first.update_attribute(:unmapped_guest, true)
      pools_count = @org.active_pools_count
      assert_equal pools_count, 2
    end

    def test_audit_manifest_action
      current_time = Time.now
      travel_to current_time do
        @org.audit_manifest_action("manifest updated")
      end
      assert_equal @org.manifest_refreshed_at.to_i, current_time.to_i
    end

    def test_manifest_history
      @org.expects(:imports).returns([{'foo' => 'bar' }, {'foo' => 'bar'}])
      assert_equal 'bar', @org.manifest_history[0].foo
    end
  end
end
