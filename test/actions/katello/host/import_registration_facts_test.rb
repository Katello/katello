require 'katello_test_helper'

module Katello::Host
  class ImportRegistrationFactsTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryBot::Syntax::Methods

    before do
      User.current = users(:admin)
      @organization = katello_organizations(:acme_corporation)
      @host = FactoryBot.create(:host, :with_content, :with_subscription,
                                :content_view => katello_content_views(:library_dev_view),
                                :lifecycle_environment => katello_environments(:library))
    end

    let(:action_class) { ::Actions::Katello::Host::ImportRegistrationFacts }
    let(:facts) { { 'network.hostname' => @host.name, 'distribution.name' => 'Red Hat Enterprise Linux' } }

    describe 'plan' do
      it 'raises when host is not persisted' do
        assert_raises(ArgumentError) do
          ::ForemanTasks.sync_task(action_class, ::Host::Managed.new, facts)
        end
      end

      it 'raises when facts are blank' do
        assert_raises(ArgumentError) do
          ::ForemanTasks.sync_task(action_class, @host, {})
        end
      end

      it 'raises when host has no subscription facet' do
        host = FactoryBot.create(:host, :with_content,
                                 :content_view => katello_content_views(:library_dev_view),
                                 :lifecycle_environment => katello_environments(:library))
        assert_raises(ArgumentError) do
          ::ForemanTasks.sync_task(action_class, host, facts)
        end
      end

      it 'stores subscription facet uuid as expected_uuid' do
        action = create_and_plan_action(action_class, @host, facts)
        assert_equal @host.subscription_facet.uuid, action.input[:expected_uuid]
      end
    end

    describe 'run' do
      it 'imports facts and refreshes statuses when uuid matches' do
        ::Katello::Host::SubscriptionFacet.expects(:update_facts).with(@host, facts).once
        ::Host::Managed.any_instance.expects(:refresh_statuses).with([::Katello::ErrataStatus, ::Katello::RhelLifecycleStatus]).once
        ::ForemanTasks.sync_task(action_class, @host, facts)
      end

      it 'skips import when host is not found by id+uuid (deleted or re-registered)' do
        ::Katello::Host::SubscriptionFacet.expects(:update_facts).never
        ::Host::Managed.any_instance.expects(:refresh_statuses).never
        # Stub the uuid at plan time so the stored expected_uuid won't match the
        # real DB value, causing find_by to return nil in run.
        @host.subscription_facet.stubs(:uuid).returns('stale-uuid')
        ::ForemanTasks.sync_task(action_class, @host, facts)
      end
    end
  end
end
