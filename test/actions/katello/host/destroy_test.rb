require 'katello_test_helper'

module Katello::Host
  class DestroyTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryGirl::Syntax::Methods

    before :all do
      User.current = users(:admin)
      @content_view = katello_content_views(:library_dev_view)
      @library = katello_environments(:library)
      @host = FactoryGirl.build(:host, :with_content, :with_subscription, :content_view => @content_view,
                                 :lifecycle_environment => @library)
    end

    describe 'Host Destroy' do
      let(:action_class) { ::Actions::Katello::Host::Destroy }
      let(:candlepin_destroy_class) { ::Actions::Candlepin::Consumer::Destroy }
      let(:pulp_destroy_class) { ::Actions::Pulp::Consumer::Destroy }

      it 'plans with default values' do
        action = create_action action_class
        action.stubs(:action_subject).with(@host)
        @host.expects(:destroy).returns(true)
        @host.content_facet.expects(:destroy!)
        @host.subscription_facet.expects(:destroy!)

        plan_action action, @host

        assert_action_planed_with action, candlepin_destroy_class, :uuid => @host.subscription_facet.uuid
        assert_action_planed_with action, pulp_destroy_class, :uuid => @host.content_facet.uuid
      end

      it 'ignores candlepin GONE' do
        action = create_action action_class
        action.stubs(:action_subject).with(@host)
        @host.expects(:destroy).returns(true)
        @host.content_facet.expects(:destroy!)
        @host.subscription_facet.expects(:destroy!)

        plan_action action, @host
      end

      it 'plans with unregistering true' do
        action = create_action action_class
        action.stubs(:action_subject).with(@host)
        @host.content_facet.expects(:destroy!).never
        @host.subscription_facet.expects(:destroy!)

        subscription_uuid = @host.subscription_facet.uuid
        content_uuid = @host.content_facet.uuid
        plan_action action, @host, :unregistering => true

        assert_action_planed_with action, candlepin_destroy_class, :uuid => subscription_uuid
        assert_action_planed_with action, pulp_destroy_class, :uuid => content_uuid

        @host.reload
        assert_nil @host.content_facet.uuid
      end

      it 'plans with organization_destroy true' do
        uuid = @host.content_facet.uuid
        @host.content_facet.expects(:destroy!)
        action = create_action action_class
        action.stubs(:action_subject).with(@host)

        plan_action action, @host, :organization_destroy => true

        refute_action_planned action, candlepin_destroy_class
        assert_action_planed_with action, pulp_destroy_class, :uuid => uuid
      end
    end
  end
end
