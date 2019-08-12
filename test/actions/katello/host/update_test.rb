require 'katello_test_helper'

module Katello::Host
  class UpdateTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryBot::Syntax::Methods

    before :all do
      User.current = users(:admin)
      @content_view = katello_content_views(:library_dev_view)
      @library = katello_environments(:library)
      @dev = katello_environments(:dev)
      @host = FactoryBot.create(:host, :with_content, :with_subscription, :content_view => @content_view,
                                 :lifecycle_environment => @library)
    end

    let(:action_class) { ::Actions::Katello::Host::Update }
    let(:action) { create_action action_class }

    describe 'Host Update without consumer params and updated environment and autoheal' do
      it 'plans' do
        action.stubs(:action_subject).with(@host)

        @host.content_facet.lifecycle_environment = @dev

        plan_action action, @host
        refute_action_planed action, ::Actions::Candlepin::Consumer::AutoAttachSubscriptions
        assert_action_planed_with action, ::Actions::Candlepin::Consumer::Update, @host.subscription_facet.uuid, @host.subscription_facet.consumer_attributes
      end
    end

    describe 'Host Update with consumer params and updated environment and autoheal' do
      it 'plans' do
        action.stubs(:action_subject).with(@host)
        consumer_params = {'autoheal' => true}
        consumer_params[:facts] = {'memory.memtotal' => '16 GB'}

        plan_action action, @host, consumer_params

        assert_action_planed_with action, ::Actions::Candlepin::Consumer::AutoAttachSubscriptions, :uuid => @host.subscription_facet.uuid
        assert_action_planed_with action, ::Actions::Candlepin::Consumer::Update, @host.subscription_facet.uuid, consumer_params
      end
    end

    describe 'Host Update with consumer params with nil facts' do
      it 'plans' do
        action.stubs(:action_subject).with(@host)
        consumer_params = {'autoheal' => true}
        consumer_params[:facts] = nil

        plan_action action, @host, consumer_params

        assert_action_planed_with action, ::Actions::Candlepin::Consumer::AutoAttachSubscriptions, :uuid => @host.subscription_facet.uuid
        assert_action_planed_with action, ::Actions::Candlepin::Consumer::Update, @host.subscription_facet.uuid, consumer_params
      end
    end

    describe 'Host Update without subscription facet' do
      it 'plans' do
        @host.subscription_facet.destroy!
        @host.reload
        action.stubs(:action_subject).with(@host)

        plan_action action, @host

        refute_action_planed action, ::Actions::Candlepin::Consumer::AutoAttachSubscriptions
        refute_action_planed action, ::Actions::Candlepin::Consumer::Update
      end
    end

    describe 'Host Update without any facet' do
      it 'plans' do
        @host.subscription_facet.destroy!
        @host.content_facet.destroy!
        @host.reload
        action.stubs(:action_subject).with(@host)

        plan_action action, @host

        refute_action_planed action, ::Actions::Candlepin::Consumer::AutoAttachSubscriptions
        refute_action_planed action, ::Actions::Candlepin::Consumer::Update
      end
    end

    describe 'Host update using facet params' do
      it 'plans' do
        @host.subscription_facet.stubs(:consumer_attributes).returns('autoheal' => true)
        action.stubs(:action_subject).with(@host)

        plan_action action, @host

        # we shouldn't plan AutoAttach just because the facet has it enabled
        refute_action_planed action, ::Actions::Candlepin::Consumer::AutoAttachSubscriptions
        assert_action_planed_with action, ::Actions::Candlepin::Consumer::Update, @host.subscription_facet.uuid, @host.subscription_facet.consumer_attributes
      end
    end

    describe 'Host update with overridden DMI UUID' do
      it 'overrides the value sent to candlepin' do
        ::Setting[:host_dmi_uuid_duplicates] = ['duplicate-dmi-uuid']
        consumer_params = {facts: {'dmi.system.uuid' => 'duplicate-dmi-uuid'}}
        action.stubs(:action_subject).with(@host)

        plan_action action, @host, consumer_params

        override = @host.subscription_facet.dmi_uuid_override
        assert_equal override.value, consumer_params[:facts]['dmi.system.uuid']

        assert_action_planed_with action, ::Actions::Candlepin::Consumer::Update, @host.subscription_facet.uuid, consumer_params
      end
    end
  end
end
