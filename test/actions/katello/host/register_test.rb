require 'katello_test_helper'

module Katello::Host
  class RegisterTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryGirl::Syntax::Methods

    before :all do
      User.current = users(:admin)
      @content_view = katello_content_views(:library_dev_view)
      @library = katello_environments(:library)
      @content_view_environment = katello_content_view_environments(:library_dev_view_library)
      @activation_key = katello_activation_keys(:library_dev_staging_view_key)
      @host_collection = katello_host_collections(:simple_host_collection)
      Dynflow::Testing::DummyPlannedAction.any_instance.stubs(:error).returns(nil)
      Dynflow::Testing::DummyPlannedAction.any_instance.stubs(:input).returns(response: {:uuid => ' '})
    end

    let(:action_class) { ::Actions::Katello::Host::Register }
    let(:candlepin_class) { ::Actions::Candlepin::Consumer::Create }
    let(:pulp_class) { ::Actions::Pulp::Consumer::Create }
    let(:rhsm_params) { {:name => 'foobar', :facts => {'a' => 'b'}, :type => 'system'} }

    describe 'Host Register' do
      it 'plans' do
        action = create_action action_class
        new_host = Host::Managed.new(:name => 'foobar', :managed => false, :organization => @library.organization)
        action.stubs(:action_subject).with(new_host)
        plan_action action, new_host, rhsm_params, @content_view_environment

        assert_action_planed_with(action, candlepin_class, :cp_environment_id => @content_view_environment.cp_id,
                                  :consumer_parameters => rhsm_params, :activation_keys => [])

        assert_action_planed_with(action, pulp_class) do |params, *_|
          params[:uuid].must_be_kind_of Dynflow::ExecutionPlan::OutputReference
          params[:uuid].subkeys.must_equal %w(response uuid)
        end

        refute_action_planned(action, Actions::Katello::Host::Unregister)

        assert_equal @library, new_host.content_facet.lifecycle_environment
        assert_equal @content_view, new_host.content_facet.content_view
      end

      it 'plans with activation keys' do
        @activation_key.host_collections << @host_collection
        Katello::ActivationKey.any_instance.stubs(:cp_name).returns('cp_name_baz')
        cvpe = Katello::ContentViewEnvironment.where(:content_view_id => @activation_key.content_view, :environment_id => @activation_key.environment).first
        action = create_action action_class
        new_host = Host::Managed.new(:name => 'foobar', :managed => false, :organization => @host_collection.organization)
        action.stubs(:action_subject).with(new_host)

        activation_keys = []
        activation_keys << @activation_key
        plan_action action, new_host, rhsm_params, nil, activation_keys

        assert_action_planed_with(action, candlepin_class, :cp_environment_id => cvpe.cp_id,
                                  :consumer_parameters => rhsm_params, :activation_keys => [@activation_key.cp_name])
        refute_action_planned(action, Actions::Katello::Host::Unregister)

        assert_equal @activation_key.environment, new_host.content_facet.lifecycle_environment
        assert_equal @activation_key.content_view, new_host.content_facet.content_view

        assert_equal @activation_key.environment, new_host.content_facet.lifecycle_environment
        assert_equal @activation_key.content_view, new_host.content_facet.content_view

        assert_includes new_host.host_collections, @host_collection
      end

      it 'plans with existing host' do
        @host = FactoryGirl.create(:host, :with_content, :with_subscription, :content_view => @content_view,
                                   :lifecycle_environment => @library, :organization => @content_view.organization)
        action = create_action action_class
        action.stubs(:action_subject).with(@host)
        plan_action action, @host, rhsm_params, @content_view_environment

        assert_action_planned_with(action, Actions::Katello::Host::Unregister, @host)
      end
    end
  end
end
