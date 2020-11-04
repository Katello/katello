require 'katello_test_helper'

module Katello::Host
  class UploadPackageProfileTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryBot::Syntax::Methods

    before :all do
      User.current = users(:admin)
      @host = FactoryBot.build(:host, :with_content, :with_subscription, :content_view => katello_content_views(:library_dev_view),
                                 :lifecycle_environment => katello_environments(:library), :id => 343)
    end

    describe 'Host UploadPackageProfile' do
      let(:action_class) { ::Actions::Katello::Host::UploadPackageProfile }

      it 'plans' do
        profile = [{:name => "foo", :version => "1", :release => "3"}]
        action = create_action action_class
        action.stubs(:action_subject).with(@host)

        plan_action action, @host, profile.to_json

        assert_action_planed_with action, Actions::Katello::Host::GenerateApplicability, [@host]
      end

      it 'runs' do
        profile = [{:name => "foo", :version => "1", :release => "3"}]
        action = create_action action_class
        action.stubs(:action_subject).with(@host)

        ::Host.expects(:find_by).returns(@host)
        mock_consumer = mock
        mock_consumer.expects(:upload_package_profile)
        ::Katello::Pulp::Consumer.expects(:new).returns(mock_consumer)
        @host.expects(:import_package_profile).with(any_parameters)

        plan_action action, @host, profile.to_json
        run_action action
      end

      it 'runs and no raised exception when pulp 404s' do
        profile = [{:name => "foo", :version => "1", :release => "3"}]
        action = create_action action_class
        action.stubs(:action_subject).with(@host)

        ::Host.expects(:find_by).returns(@host)
        mock_consumer = mock
        mock_consumer.expects(:upload_package_profile).raises(RestClient::ResourceNotFound)
        ::Katello::Pulp::Consumer.expects(:new).returns(mock_consumer)
        @host.expects(:import_package_profile).with(any_parameters).never

        plan_action action, @host, profile.to_json
        run_action action
      end

      it 'runs and no raised exception if host not found' do
        profile = [{:name => "foo", :version => "1", :release => "3"}]
        action = create_action action_class
        action.stubs(:action_subject).with(@host)

        ::Host.expects(:find_by).returns(nil)
        ::Katello::Pulp::Consumer.expects(:new).never

        plan_action action, @host, profile.to_json
        run_action action
      end

      it 'runs and no raised exception if host sub facet not found' do
        profile = [{:name => "foo", :version => "1", :release => "3"}]
        action = create_action action_class
        action.stubs(:action_subject).with(@host)

        ::Host.expects(:find_by).returns(@host)
        @host.expects(:content_facet).returns(nil)
        ::Katello::Pulp::Consumer.expects(:new).never

        plan_action action, @host, profile.to_json
        run_action action
      end

      it 'runs and no raised exception if host not found via FK error' do
        profile = [{:name => "foo", :version => "1", :release => "3"}]
        action = create_action action_class
        action.stubs(:action_subject).with(@host)

        ::Host.expects(:find_by).returns(@host)
        mock_consumer = mock
        mock_consumer.expects(:upload_package_profile)
        ::Katello::Pulp::Consumer.expects(:new).returns(mock_consumer)
        @host.expects(:import_package_profile).with(any_parameters).raises(ActiveRecord::InvalidForeignKey)

        plan_action action, @host, profile.to_json
        run_action action
      end

      it 'runs and skips Pulp::Consumer with Pulp 3 yum support' do
        profile = [{:name => "foo", :version => "1", :release => "3"}]
        action = create_action action_class
        action.stubs(:action_subject).with(@host)

        mock_smart_proxy = mock
        mock_smart_proxy.expects(:pulp3_repository_type_support?).returns(true)
        ::SmartProxy.expects(:pulp_primary).returns(mock_smart_proxy)
        ::Host.expects(:find_by).returns(@host)
        ::Katello::Pulp::Consumer.expects(:new).never
        @host.expects(:import_package_profile).with(any_parameters)

        plan_action action, @host, profile.to_json
        run_action action
      end
    end
  end
end
