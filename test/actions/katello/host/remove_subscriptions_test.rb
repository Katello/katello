require 'katello_test_helper'

module Katello::Host
  class RemoveSubscriptionsTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryBot::Syntax::Methods

    before :all do
      User.current = users(:admin)
      @host = FactoryBot.create(:host, :with_subscription)
      @pool = katello_pools(:pool_one)
    end

    describe 'remove subscriptions' do
      let(:action_class) { ::Actions::Katello::Host::RemoveSubscriptions }

      it 'plans' do
        action = create_action action_class
        action.expects(:action_subject).with(@host)
        pools_with_quantities = [::Katello::PoolWithQuantities.new(@pool, [1, 2])]

        entitlements = [{'id' => 3, 'pool' => {'id' => 'foo'}}, {'id' => 4, 'pool' => {'id' => 'bar'}}]
        candlepin_consumer = mock
        candlepin_consumer.expects(:filter_entitlements).returns(entitlements)
        @host.subscription_facet.expects(:candlepin_consumer).returns(candlepin_consumer)

        plan_action action, @host, pools_with_quantities

        assert_action_planed_with action, Actions::Candlepin::Consumer::RemoveSubscription, :uuid => @host.subscription_facet.uuid,
                                          :entitlement_id => 3, :pool_id => 'foo'
        assert_action_planed_with action, Actions::Candlepin::Consumer::RemoveSubscription, :uuid => @host.subscription_facet.uuid,
                                          :entitlement_id => 4, :pool_id => 'bar'
      end
    end
  end
end
