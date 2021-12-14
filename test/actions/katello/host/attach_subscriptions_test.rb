require 'katello_test_helper'

module Katello::Host
  class AttachSubscriptionsTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryBot::Syntax::Methods

    before :all do
      User.current = users(:admin)
      @host = FactoryBot.create(:host, :with_subscription)
      @pool = katello_pools(:pool_one)
    end

    describe 'attach subscriptions' do
      let(:action_class) { ::Actions::Katello::Host::AttachSubscriptions }

      it 'plans success' do
        action = create_action action_class
        action.expects(:action_subject).with(@host)

        candlepin_consumer = mock
        candlepin_consumer.expects(:pool_ids).returns([])
        @host.subscription_facet.expects(:candlepin_consumer).returns(candlepin_consumer)

        pools_with_quantities = [::Katello::PoolWithQuantities.new(@pool, [1, 2])]

        plan_action action, @host, pools_with_quantities

        assert_action_planned_with action, Actions::Candlepin::Consumer::AttachSubscription, :uuid => @host.subscription_facet.uuid,
                                  :quantity => 1, :pool_uuid => @pool.cp_id
        assert_action_planned_with action, Actions::Candlepin::Consumer::AttachSubscription, :uuid => @host.subscription_facet.uuid,
                                          :quantity => 2, :pool_uuid => @pool.cp_id
      end

      it 'plans failure' do
        action = create_action action_class
        action.expects(:action_subject).with(@host)

        @host.expects(:subscription_facet).returns(nil)

        pools_with_quantities = []

        assert_raises RuntimeError do
          plan_action action, @host, pools_with_quantities
        end
      end
    end
  end
end
