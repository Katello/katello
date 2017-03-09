require 'katello_test_helper'

module Katello::Host
  class UpdateContentOverridesTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryGirl::Syntax::Methods

    before :all do
      User.current = users(:admin)
      @host = FactoryGirl.create(:host, :with_subscription)
    end

    describe 'auto attach subscriptions' do
      let(:action_class) { ::Actions::Katello::Host::UpdateContentOverrides }

      it 'plans' do
        action = create_action action_class
        action.expects(:action_subject).with(@host)

        content_overrides = [::Katello::ContentOverride.new("foo", :enabled => 1), ::Katello::ContentOverride.new("bar", :enabled => nil)]
        plan_action action, @host, content_overrides

        assert_action_planed_with action, Actions::Candlepin::Consumer::UpdateContentOverrides,
                                          :uuid => @host.subscription_facet.uuid,
                                          :content_overrides => content_overrides.map(&:to_entitlement_hash)
      end
    end
  end
end
