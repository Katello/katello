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
      @hypervisor_results = { 'created' =>  [{ :name => 'hypervisor' }], 'updated' => [], 'deleted' => [] }
      Dynflow::Testing::DummyPlannedAction.any_instance.stubs(:error).returns(nil)

      @host = FactoryGirl.build(:host, :with_subscription, :content_view => @content_view,
                                :lifecycle_environment => @content_view_environment,
                                :content_host => katello_systems(:simple_server))
      ::Katello::Hypervisor.stubs(:find_by_name).returns(true)
      ::Katello::KTEnvironment.stubs(:find).returns(@content_view_environment)
      ::Katello::ContentView.stubs(:find).returns(@content_view)
    end

    let(:action_class) { ::Actions::Katello::Host::Hypervisors }

    # rubocop:disable MethodCalledOnDoEndBlock
    describe 'Hypervisors Update' do
      it 'hypervisor' do
        ::Katello::Host::SubscriptionAspect.expects(:find_or_create_host_for_hypervisor).with do |name, *_|
          name.must_equal 'hypervisor'
        end.returns(@host)
        action = create_action(::Actions::Katello::Host::HypervisorsUpdate)
        plan_action(action, @content_view_environment, @content_view, @hypervisor_results)
        finalize_action(action)
      end

      it 'hypervisor duplicate' do
        ::Host.stubs(:find_by_name).returns(@host)
        @host.organization = @organization
        ::Katello::Host::SubscriptionAspect.expects(:find_or_create_host_for_hypervisor).with do |name, *_|
          name.must_equal "virt-who-hypervisor-#{@content_view.organization.id}"
        end.returns(@host)
        action = create_action(::Actions::Katello::Host::HypervisorsUpdate)
        plan_action(action, @content_view_environment, @content_view, @hypervisor_results)
        finalize_action(action)
      end
    end
    # rubocop:enable MethodCalledOnDoEndBlock
  end
end
