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
                                 :lifecycle_environment => @library, :content_host => katello_systems(:simple_server))
      @host.content_host.stubs(:pools).returns([{"id" => "fake"}])
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
        @host.content_host.expects(:destroy!)

        plan_action action, @host

        assert_action_planed_with action, candlepin_destroy_class, :uuid => @host.subscription_facet.uuid
        assert_action_planed_with action, pulp_destroy_class, :uuid => @host.content_facet.uuid
      end

      it 'plans with destroy_object false' do
        action = create_action action_class
        action.stubs(:action_subject).with(@host)
        @host.content_facet.expects(:destroy!)
        @host.subscription_facet.expects(:destroy!)
        @host.content_host.expects(:destroy!)
        @host.expects(:destroy).never

        plan_action action, @host, :destroy_object => false

        assert_action_planed_with action, candlepin_destroy_class, :uuid => @host.subscription_facet.uuid
        assert_action_planed_with action, pulp_destroy_class, :uuid => @host.content_facet.uuid
      end

      it 'plans with destroy_facets false' do
        action = create_action action_class
        action.stubs(:action_subject).with(@host)
        @host.content_facet.expects(:destroy!).never
        @host.subscription_facet.expects(:destroy!).never
        @host.content_host.expects(:destroy!)

        subscription_uuid = @host.subscription_facet.uuid
        content_uuid = @host.content_facet.uuid
        plan_action action, @host, :destroy_object => false, :destroy_facets => false

        assert_action_planed_with action, candlepin_destroy_class, :uuid => subscription_uuid
        assert_action_planed_with action, pulp_destroy_class, :uuid => content_uuid

        assert_nil @host.content_facet.uuid
        assert_nil @host.subscription_facet.uuid
      end

      it 'plans with skip_candlepin true' do
        action = create_action action_class
        action.stubs(:action_subject).with(@host)

        plan_action action, @host, :destroy_object => false, :skip_candlepin => true

        refute_action_planned action, candlepin_destroy_class
        assert_action_planed_with action, pulp_destroy_class, :uuid => @host.content_facet.uuid
      end
    end
  end
end
