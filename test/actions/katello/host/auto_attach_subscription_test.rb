require 'katello_test_helper'

module Katello::Host
  class AutoAttachSubscriptionsTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryBot::Syntax::Methods

    before :all do
      User.current = users(:admin)
      @host = FactoryBot.create(:host, :with_subscription)
    end

    describe 'auto attach subscriptions' do
      let(:action_class) { ::Actions::Katello::Host::AutoAttachSubscriptions }

      it 'plans' do
        action = create_action action_class
        action.expects(:action_subject).with(@host)

        plan_action action, @host

        assert_action_planned_with action, Actions::Candlepin::Consumer::AutoAttachSubscriptions, :uuid => @host.subscription_facet.uuid
      end
    end
  end
end
