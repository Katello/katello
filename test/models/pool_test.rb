#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'minitest_helper'

module Katello
  class PoolTest < ActiveSupport::TestCase

    def test_active
      active_pool = FactoryGirl.build(:pool, :active)
      inactive_pool = FactoryGirl.build(:pool, :inactive)
      all_subscriptions = [active_pool, inactive_pool]
      active_subscriptions = Pool.active(all_subscriptions)
      assert_equal active_subscriptions, all_subscriptions - [inactive_pool]
    end

    def test_expiring_soon
      not_expiring_soon = FactoryGirl.build(:pool, :not_expiring_soon)
      expiring_soon_pool = FactoryGirl.build(:pool, :expiring_soon)
      all_subscriptions = [not_expiring_soon, expiring_soon_pool]
      expiring_soon_subscriptions = Pool.expiring_soon(all_subscriptions)
      assert_equal expiring_soon_subscriptions, all_subscriptions - [not_expiring_soon]
    end

    def test_recently_expired
      unexpired = FactoryGirl.build(:pool, :unexpired)
      recently_expired = FactoryGirl.build(:pool, :recently_expired)
      all_subscriptions = [unexpired, recently_expired]
      expired_subscriptions = Pool.recently_expired(all_subscriptions)
      assert_equal expired_subscriptions, all_subscriptions - [unexpired]
    end

    def test_recently_expired_does_not_get_long_expired_subscriptions
      unexpired = FactoryGirl.build(:pool, :unexpired)
      recently_expired = FactoryGirl.build(:pool, :recently_expired)
      long_expired = FactoryGirl.build(:pool, :long_expired)

      all_subscriptions = [unexpired, recently_expired, long_expired]
      expired_subscriptions = Pool.recently_expired(all_subscriptions)
      assert_equal expired_subscriptions, all_subscriptions - [unexpired, long_expired]
    end

    def test_find_by_organization_and_id
      test_raises(ActiveRecord::RecordNotFound) do
        Pool.find_by_organization_and_id!(katello_organizations(:acme_corporation), 3)
      end
    end

    def test_systems
      active_pool = FactoryGirl.build(:pool, :active)
      systems = [katello_systems(:simple_server)]
      System.expects(:all_by_pool_id).with(active_pool.cp_id).returns(systems)
      assert_equal active_pool.systems, systems
    end
  end

end
