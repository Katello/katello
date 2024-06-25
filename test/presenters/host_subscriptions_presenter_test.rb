require 'katello_test_helper'

module Katello
  class HostSubscriptionsPresenterTest < ActiveSupport::TestCase
    let(:presenter) { ::Katello::HostSubscriptionsPresenter.new(@host) }

    def test_host_with_subscriptions
      redhat_product = katello_products(:redhat)
      fedora_product = katello_products(:fedora)

      @host = FactoryBot.create(:host, :with_subscription)
      redhat_pool = FactoryBot.create(:katello_pool, cp_id: '12345', products: [redhat_product], organization: @host.organization)
      custom_pool = FactoryBot.create(:katello_pool, cp_id: '6789', products: [fedora_product], organization: @host.organization)

      @host.subscription_facet.pools << redhat_pool
      @host.subscription_facet.pools << custom_pool

      entitlements = [
        {
          'pool' => {
            'id' => redhat_pool.cp_id,
          },
          quantity: 15,
        },
        {
          'pool' => {
            'id' => custom_pool.cp_id,
          },
          quantity: 4,
        }
      ]

      ::Katello::Candlepin::Consumer.any_instance.expects(:entitlements).returns(entitlements)

      assert_equal 2, presenter.subscriptions.length
    end

    def test_host_without_subscriptions
      @host = FactoryBot.create(:host)

      ::Katello::Candlepin::Consumer.any_instance.expects(:entitlements).never

      assert_equal 0, presenter.subscriptions.length
    end
  end
end
