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

    describe 'update content_overrides with pruning' do
      let(:action_class) { ::Actions::Katello::Host::UpdateContentOverrides }

      it 'plans' do
        action = create_action action_class
        action.expects(:action_subject).with(@host)

        content_overrides = [::Katello::ContentOverride.new("foo", :enabled => 1), ::Katello::ContentOverride.new("bar", :enabled => nil)]
        @host.expects(:valid_content_override_label?).with(content_overrides.first.content_label).returns(true)
        @host.expects(:valid_content_override_label?).with(content_overrides.last.content_label).returns(false)

        ::Katello::Resources::Candlepin::Consumer.expects(:update_content_overrides).
                                                  with(@host.subscription_facet.uuid,
                                                       [content_overrides.first.to_entitlement_hash])

        planned_action = plan_action action, @host, content_overrides

        run_action planned_action do |_|
          ::Host.expects(:find).returns(@host)
        end
      end
    end

    describe 'update content_overrides without pruning' do
      let(:action_class) { ::Actions::Katello::Host::UpdateContentOverrides }

      it 'plans' do
        action = create_action action_class
        action.expects(:action_subject).with(@host)

        content_overrides = [::Katello::ContentOverride.new("foo", :enabled => 1), ::Katello::ContentOverride.new("bar", :enabled => nil)]
        @host.expects(:valid_content_override_label?).never

        ::Katello::Resources::Candlepin::Consumer.expects(:update_content_overrides).
                                                  with(@host.subscription_facet.uuid,
                                                       content_overrides.map(&:to_entitlement_hash))

        planned_action = plan_action action, @host, content_overrides, false

        run_action planned_action do |_|
          ::Host.expects(:find).returns(@host)
        end
      end
    end
  end
end
