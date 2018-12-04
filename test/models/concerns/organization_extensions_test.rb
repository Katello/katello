# encoding: utf-8

require 'katello_test_helper'

module Katello
  class OrganizationExtensionsTest < ActiveSupport::TestCase
    def setup
      User.current = User.find(users(:admin).id)
      set_default_location
      @org = get_organization(:empty_organization)
      @org.label = @org.label.tr(' ', ' ')
    end

    def test_active_pools_count
      pools_count = @org.active_pools_count
      assert_equal pools_count, 3

      @org.pools.first.update_attribute(:unmapped_guest, true)
      pools_count = @org.active_pools_count
      assert_equal pools_count, 2
    end
  end
end
