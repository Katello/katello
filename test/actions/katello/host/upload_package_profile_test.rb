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
      @mock_smart_proxy = mock
      ::SmartProxy.stubs(:pulp_primary).returns(@mock_smart_proxy)
      @mock_smart_proxy.stubs(:has_feature?).with(::SmartProxy::PULP_FEATURE).returns(true)
    end

    describe 'Host UploadPackageProfile' do
      let(:action_class) { ::Actions::Katello::Host::UploadPackageProfile }

      it 'runs' do
        profile = [{:name => "foo", :version => "1", :release => "3"}]
        action = create_action action_class
        action.stubs(:action_subject).with(@host)

        ::Host.expects(:find_by).returns(@host)
        ::Katello::Host::PackageProfileUploader.any_instance.expects(:upload)
        ::Katello::Host::PackageProfileUploader.any_instance.expects(:trigger_applicability_generation)

        plan_action action, @host, profile.to_json
        run_action action
      end

      it 'runs and no raised exception if host not found' do
        profile = [{:name => "foo", :version => "1", :release => "3"}]
        action = create_action action_class
        action.stubs(:action_subject).with(@host)

        ::Host.expects(:find_by).twice.returns(nil)

        plan_action action, @host, profile.to_json
        run_action action
      end

      it 'runs and no raised exception if host sub facet not found' do
        profile = [{:name => "foo", :version => "1", :release => "3"}]
        action = create_action action_class
        action.stubs(:action_subject).with(@host)

        ::Host.expects(:find_by).twice.returns(@host)
        @host.expects(:content_facet).returns(nil)

        plan_action action, @host, profile.to_json
        run_action action
      end

      it 'runs and no raised exception if host not found via FK error' do
        profile = [{:name => "foo", :version => "1", :release => "3"}]
        action = create_action action_class
        action.stubs(:action_subject).with(@host)

        ::Host.expects(:find_by).twice.returns(@host)
        @host.expects(:import_package_profile).with(any_parameters).raises(ActiveRecord::InvalidForeignKey)

        plan_action action, @host, profile.to_json
        run_action action
      end
    end
  end
end
