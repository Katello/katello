require 'katello_test_helper'

module Katello::Host
  class HypervisorsUpdateTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryBot::Syntax::Methods

    before :each do
      User.current = users(:admin)
      @organization = FactoryBot.build(:katello_organization)
      @content_view = katello_content_views(:library_dev_view)
      @content_view_environment = katello_content_view_environments(:library_dev_view_library)
      Dynflow::Testing::DummyPlannedAction.any_instance.stubs(:error).returns(nil)

      @host = FactoryBot.create(:host, :with_subscription, :content_view => @content_view,
                                :lifecycle_environment => @content_view_environment, :organization => @organization)

      old_name = @host.name
      @hypervisor_name = "virt-who-#{@host.name}-#{@organization.id}"
      @host.update_attributes!(:name => @hypervisor_name)
      @hypervisor_results = [{ :name => old_name, :uuid => @host.subscription_facet.uuid, :organization_label => @organization.label }]
      ::Katello::Resources::Candlepin::Consumer.stubs(:get).returns(
        [
          {
            uuid: @host.subscription_facet.uuid,
            entitlementStatus: Katello::SubscriptionStatus::UNKNOWN,
            'guestIds' => ['test-id-1'],
            'entitlementCount' => 0
          }
        ]
      )
    end

    let(:action_class) { ::Actions::Katello::Host::Hypervisors }

    describe 'Hypervisors Update' do
      it 'new hypervisor' do
        @host.subscription_facet.destroy!
        @host.reload

        action = create_action(::Actions::Katello::Host::HypervisorsUpdate)

        plan_action(action, :hypervisors => @hypervisor_results)
        finalize_action(action)

        @host.reload
        assert_not_nil @host.subscription_facet
      end

      it 'existing hypervisor, no facet' do
        @host.subscription_facet.delete
        @host.save!
        action = create_action(::Actions::Katello::Host::HypervisorsUpdate)

        plan_action(action, :hypervisors => @hypervisor_results)
        finalize_action(action)
        @host.reload
        assert_not_nil @host.subscription_facet
      end

      it 'existing hypervisor, renamed' do
        @hypervisor_results[0][:name] = 'hypervisor.renamed'
        action = create_action(::Actions::Katello::Host::HypervisorsUpdate)

        plan_action(action, :hypervisors => @hypervisor_results)
        assert_difference('::Katello::Host::SubscriptionFacet.count', 0) do
          finalize_action(action)
        end
      end

      it 'existing hypervisor, no org' do
        Dynflow::Testing::DummyPlannedAction.any_instance.stubs(:error).returns("ERROR")
        @host.organization = nil
        @host.save!

        action = create_action(::Actions::Katello::Host::HypervisorsUpdate)

        plan_action(action, :hypervisors => @hypervisor_results)
        action = finalize_action(action)

        action.state.must_equal :error
        action.error.message.must_equal "Host '#{@host.name}' does not belong to an organization"
      end
    end
  end
end
