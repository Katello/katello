require 'katello_test_helper'

module Katello::Host
  class HypervisorsUpdateTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryGirl::Syntax::Methods

    before :all do
      User.current = users(:admin)
      @organization = FactoryGirl.build(:katello_organization)
      @content_view = katello_content_views(:library_dev_view)
      @content_view_environment = katello_content_view_environments(:library_dev_view_library)
      Dynflow::Testing::DummyPlannedAction.any_instance.stubs(:error).returns(nil)

      @host = FactoryGirl.build(:host, :with_subscription, :content_view => @content_view,
                                :lifecycle_environment => @content_view_environment,
                                :content_host => katello_systems(:simple_server))
      @host.organization = @organization
      @content_view.organization = @organization
      @hypervisor_results = { 'created' => [{ :name => 'hypervisor', :uuid => @host.subscription_facet.uuid }],
                              'updated' => [], 'deleted' => [] }
      ::Katello::Hypervisor.stubs(:find_by).returns(true)
      ::Katello::KTEnvironment.stubs(:find).returns(@content_view_environment)
      ::Katello::ContentView.stubs(:find).returns(@content_view)
    end

    let(:action_class) { ::Actions::Katello::Host::Hypervisors }

    # rubocop:disable MethodCalledOnDoEndBlock
    describe 'Hypervisors Update' do
      it 'new hypervisor' do
        uuid = @hypervisor_results['created'][0][:uuid]
        ::Katello::Host::SubscriptionFacet.expects(:find_by).with(:uuid => uuid).returns(nil)
        ::Host.expects(:find_by).with(:name => 'hypervisor').returns(nil)
        ::Katello::Host::SubscriptionFacet.expects(:new).returns(@host.subscription_facet)
        action = create_action(::Actions::Katello::Host::HypervisorsUpdate)
        plan_action(action, @content_view_environment, @content_view, @hypervisor_results)
        finalize_action(action)
      end

      it 'existing hypervisor, no facet' do
        uuid = @hypervisor_results['created'][0][:uuid]
        subscription_facet = @host.subscription_facet
        @host.subscription_facet = nil
        ::Katello::Host::SubscriptionFacet.expects(:find_by).with(:uuid => uuid).returns(nil)
        ::Host.expects(:find_by).with(:name => 'hypervisor').returns(@host)
        ::Katello::Host::SubscriptionFacet.expects(:new).returns(subscription_facet)
        action = create_action(::Actions::Katello::Host::HypervisorsUpdate)
        plan_action(action, @content_view_environment, @content_view, @hypervisor_results)
        finalize_action(action)
      end

      it 'existing hypervisor, renamed' do
        @hypervisor_results['created'][0][:name] = 'hypervisor.renamed'
        uuid = @hypervisor_results['created'][0][:uuid]
        @host.subscription_facet.host_id = @host.id
        ::Katello::Host::SubscriptionFacet.expects(:find_by).with(:uuid => uuid).returns(@host.subscription_facet)
        ::Host.expects(:find_by).never
        ::Katello::Host::SubscriptionFacet.expects(:new).never
        action = create_action(::Actions::Katello::Host::HypervisorsUpdate)
        plan_action(action, @content_view_environment, @content_view, @hypervisor_results)
        finalize_action(action)
      end

      it 'existing hypervisor, no org' do
        Dynflow::Testing::DummyPlannedAction.any_instance.stubs(:error).returns("ERROR")
        @host.organization = nil
        uuid = @hypervisor_results['created'][0][:uuid]
        ::Katello::Host::SubscriptionFacet.expects(:find_by).with(:uuid => uuid).returns(nil)
        ::Host.expects(:find_by).with(:name => 'hypervisor').returns(@host)
        action = create_action(::Actions::Katello::Host::HypervisorsUpdate)
        plan_action(action, @content_view_environment, @content_view, @hypervisor_results)
        action = finalize_action(action)

        action.state.must_equal :error
        action.error.message.must_equal "Host 'hypervisor' does not belong to an organization"
      end

      it 'hypervisor duplicate' do
        @hypervisor_results['created'][0][:name] = 'hypervisor'
        uuid = @hypervisor_results['created'][0][:uuid]
        @host.subscription_facet.host_id = @host.id
        @content_view.organization = FactoryGirl.build(:katello_organization)
        ::Katello::Host::SubscriptionFacet.expects(:find_by).with(:uuid => uuid).returns(@host.subscription_facet)
        ::Host::Managed.expects(:new).with do |params|
          params[:name].must_equal "virt-who-hypervisor-#{@content_view.organization.id}"
        end.returns(@host)
        action = create_action(::Actions::Katello::Host::HypervisorsUpdate)
        plan_action(action, @content_view_environment, @content_view, @hypervisor_results)
        action = finalize_action(action)
        action.state.must_equal :success
      end
    end
    # rubocop:enable MethodCalledOnDoEndBlock
  end
end
