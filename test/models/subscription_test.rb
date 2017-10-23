require 'katello_test_helper'

module Katello
  class SubscriptionTest < ActiveSupport::TestCase
    def setup
      @basic = katello_subscriptions(:basic_subscription)
      @other = katello_subscriptions(:other_subscription)
    end

    def test_subscription_returns_pools
      assert @other.pools.count > 0
    end

    def test_pool_states
      pools = [FactoryGirl.build(:katello_pool, :active), FactoryGirl.build(:katello_pool, :expiring_soon)]
      @basic.stubs(:pools).returns(pools)
      assert @basic.active?
      assert @basic.expiring_soon?
      refute @basic.recently_expired?
    end

    def test_subscribable
      fedora = katello_products(:fedora)
      assert_includes Subscription.subscribable, @other

      @other.products.delete(fedora)
      assert_includes Subscription.subscribable, @other
    end

    def test_virt_who_scope
      assert_equal 1, Subscription.using_virt_who.length
    end

    def test_virt_who
      assert_equal 1, @basic.virt_who_pools.length
      assert_equal 0, @other.virt_who_pools.length
    end

    def test_virt_who?
      assert @basic.virt_who?
      refute @other.virt_who?
    end

    def test_redhat?
      assert @basic.redhat?

      Katello::Product.create!(:name => "custom_#{rand(999)}", :cp_id => @basic.product_id,
                               :organization => @basic.organization, :provider => @basic.organization.anonymous_provider)
      refute @basic.redhat?
    end
  end
end
