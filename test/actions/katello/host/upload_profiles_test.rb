require 'katello_test_helper'

module Katello::Host
  class UploadProfilesTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryBot::Syntax::Methods

    before :all do
      User.current = users(:admin)
      @host = FactoryBot.build(:host, :with_content, :with_subscription, :content_view => katello_content_views(:library_dev_view),
                                 :lifecycle_environment => katello_environments(:library), :id => 343)
    end

    describe 'Host UploadProfiles' do
      let(:action_class) { ::Actions::Katello::Host::UploadProfiles }
      let(:rpm_profiles) { [{"name" => "foo", "version" => "1", "release" => "3"}] }
      let(:enabled_repos) { [{"repositoryid" => "foo", "baseurl" => "http://foo.com"}] }
      let(:modumd_inventory) { [{"name" => "foo", "stream" => "1.1", "arch" => "x86_64"}] }
      let(:profile) do
        [
          {"content_type" => "rpm", "profile" => rpm_profiles},
          {"content_type" => "enabled_repos", "profile" => enabled_repos},
          {"content_type" => "modulemd", "profile" => modumd_inventory}
        ]
      end

      it 'plans' do
        action = create_action action_class
        action.stubs(:action_subject).with(@host)

        plan_action action, @host, profile.to_json

        assert_action_planed_with action, Actions::Katello::Host::GenerateApplicability, [@host]
      end

      it 'runs' do
        action = create_action action_class
        action.stubs(:action_subject).with(@host)

        ::Host.expects(:find_by).returns(@host).at_least_once
        mock_consumer = mock
        mock_consumer.expects(:upload_package_profile)
        ::Katello::Pulp::Consumer.expects(:new).returns(mock_consumer)
        @host.expects(:import_package_profile).with do |packages|
          expected_packages = rpm_profiles.map { |prof| ::Katello::Pulp::SimplePackage.new(prof) }
          packages.map(&:nvra).must_equal(expected_packages.map(&:nvra))
        end
        @host.expects(:import_enabled_repositories).with(enabled_repos)

        plan_action action, @host, profile.to_json
        run_action action
      end

      it 'runs and no raised exception when pulp 404s' do
        action = create_action action_class
        action.stubs(:action_subject).with(@host)

        ::Host.expects(:find_by).returns(@host).at_least_once
        mock_consumer = mock
        mock_consumer.expects(:upload_package_profile).raises(RestClient::ResourceNotFound)
        ::Katello::Pulp::Consumer.expects(:new).returns(mock_consumer)
        @host.expects(:import_package_profile).with(any_parameters).never
        @host.expects(:import_enabled_repositories).with(enabled_repos)

        plan_action action, @host, profile.to_json
        run_action action
      end

      it 'runs and no raised exception if host not found' do
        action = create_action action_class
        action.stubs(:action_subject).with(@host)

        ::Host.expects(:find_by).returns(nil)
        ::Katello::Pulp::Consumer.expects(:new).never

        plan_action action, @host, profile.to_json
        run_action action
      end

      it 'runs and no raised exception if host sub facet not found' do
        action = create_action action_class
        action.stubs(:action_subject).with(@host)

        ::Host.expects(:find_by).returns(@host).at_least_once
        @host.expects(:content_facet).returns(nil)
        ::Katello::Pulp::Consumer.expects(:new).never

        plan_action action, @host, profile.to_json
        run_action action
      end

      it 'runs and no raised exception if host not found via FK error' do
        action = create_action action_class
        action.stubs(:action_subject).with(@host)

        ::Host.expects(:find_by).returns(@host).at_least_once
        mock_consumer = mock
        mock_consumer.expects(:upload_package_profile)
        ::Katello::Pulp::Consumer.expects(:new).returns(mock_consumer)
        @host.expects(:import_package_profile).with(any_parameters).raises(ActiveRecord::InvalidForeignKey)
        @host.expects(:import_enabled_repositories).with(enabled_repos)

        plan_action action, @host, profile.to_json
        run_action action
      end
    end
  end
end
