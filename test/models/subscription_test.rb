require 'katello_test_helper'

module Katello
  class SubscriptionTest < ActiveSupport::TestCase
    def setup
      @basic = katello_subscriptions(:basic_subscription)
      @other = katello_subscriptions(:other_subscription)
    end

    def test_import_all
      org = FactoryBot.create(:organization)
      provider = FactoryBot.create(:katello_provider, organization: org)
      product = FactoryBot.create(:katello_product, organization: org, provider: provider, cp_id: '12345')
      Katello::Resources::Candlepin::Product.expects(:get).returns(
        [
          {
            'id' => product.cp_id,
            'attributes' => {},
          }
        ]
      )

      product_data = [
        {
          'id' => product.cp_id,
        }
      ]

      Katello::Resources::Candlepin::Product.expects(:all).returns(product_data)

      Subscription.import_all(org)

      refute_empty org.subscriptions
    end

    def test_subscription_returns_pools
      assert @other.pools.count > 0
    end

    def test_pool_states
      pools = [FactoryBot.build(:katello_pool, :active), FactoryBot.build(:katello_pool, :expiring_soon)]
      @basic.stubs(:pools).returns(pools)
      assert @basic.active?
      assert @basic.expiring_soon?
      refute @basic.recently_expired?
    end

    def test_subscribable
      fedora = katello_products(:fedora)
      assert_includes Subscription.subscribable, @other

      @other.pools.first.products.delete(fedora)
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

      refute @other.redhat?
    end

    def test_multi_entitlement
      assert @basic.multi_entitlement?

      refute @other.multi_entitlement?
    end
  end
end
