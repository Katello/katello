require 'katello_test_helper'

module Katello::Host
  class HypervisorsTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryGirl::Syntax::Methods

    before :all do
      User.current = users(:admin)
      @content_view = katello_content_views(:library_dev_view)
      @content_view_environment = katello_content_view_environments(:library_dev_view_library)
      @hypervisor_params = { 'hypervisor' => ['guest-1', 'guest-2'] }
      Dynflow::Testing::DummyPlannedAction.any_instance.stubs(:error).returns(nil)
    end

    describe 'Hypervisors' do
      it 'plans' do
        action = create_action(::Actions::Katello::Host::Hypervisors)
        action.execution_plan.stub_planned_action(::Actions::Candlepin::Consumer::Hypervisors) do |candlepin_action|
          candlepin_action.stubs(output: { :results => 'candlepin results' })
        end
        plan_action(action, @content_view_environment, @content_view, @hypervisor_params)
        assert_action_planed_with(action, ::Actions::Candlepin::Consumer::Hypervisors, @hypervisor_params)
        assert_action_planed_with(action, ::Actions::Katello::Host::HypervisorsUpdate) do |environment, content_view, results, *_|
          environment.must_equal @content_view_environment
          content_view.must_equal @content_view
          results.must_equal 'candlepin results'
        end
      end
    end
  end
end
