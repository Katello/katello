require 'katello_test_helper'

module Katello::Host
  class UploadProfilesTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryBot::Syntax::Methods

    before :all do
      User.current = users(:admin)
      @host = FactoryBot.create(:host, :with_content, :with_subscription, :content_view => katello_content_views(:library_dev_view),
                                 :lifecycle_environment => katello_environments(:library), :id => 343)
    end

    describe 'Host UploadProfiles' do
      let(:action_class) { ::Actions::Katello::Host::UploadProfiles }
      let(:rpm_profiles) { [{"name" => "foo", "version" => "1", "release" => "3"}] }
      let(:enabled_repos) { [{"repositoryid" => "foo", "baseurl" => "http://foo.com"}] }
      let(:modulemd_inventory) do
        [{"name" => "foo", "stream" => "1.1", "arch" => "x86_64",
          "context" => "cccc", "version" => "11111", "status" => "enabled"}]
      end

      let(:profile) do
        [
          {"content_type" => "rpm", "profile" => rpm_profiles},
          {"content_type" => "enabled_repos", "profile" => enabled_repos},
          {"content_type" => "modulemd", "profile" => modulemd_inventory}
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
        mock_consumer.expects(:upload_module_stream_profile)
        ::Katello::Pulp::Consumer.expects(:new).at_least_once.returns(mock_consumer)
        @host.expects(:import_package_profile).with do |packages|
          expected_packages = rpm_profiles.map { |prof| ::Katello::Pulp::SimplePackage.new(prof) }
          packages.map(&:nvra).must_equal(expected_packages.map(&:nvra))
        end
        @host.expects(:import_enabled_repositories).with(enabled_repos)
        @host.expects(:import_module_streams).with(modulemd_inventory)

        plan_action action, @host, profile.to_json
        run_action action
      end

      it 'selects correct modulemd payload' do
        action = create_action action_class
        action.stubs(:action_subject).with(@host)
        river = katello_module_streams(:river)
        repo = river.repositories.first.library_instance_or_self
        @host.content_facet.expects(:bound_repositories).returns([repo])

        unassociated_profile = {"name" => "foo1", "stream" => "1.1", "arch" => "x86_64",
                                "context" => "cccc", "version" => "11111", "status" => "enabled"}

        modulemd_inventory_multiple = [
          {"name" => river.name, "stream" => river.stream, "arch" => "x86_64",
           "context" => "cccc", "version" => river.version + '1', "status" => "enabled"},
          unassociated_profile
        ]

        profile1 = [
          {"content_type" => "rpm", "profile" => rpm_profiles},
          {"content_type" => "enabled_repos", "profile" => enabled_repos},
          {"content_type" => "modulemd", "profile" => modulemd_inventory_multiple}
        ]

        ::Host.expects(:find_by).returns(@host).at_least_once
        mock_consumer = mock
        mock_consumer.expects(:upload_package_profile)
        mock_consumer.expects(:upload_module_stream_profile).with do |args|
          assert_equal 2, args.size
          args.first["name"].must_equal(river.name)
          args.first["stream"].must_equal(river.stream)
          args.first["version"].must_equal(river.version)
          args.last['name'].must_equal(unassociated_profile["name"])
          args.last['stream'].must_equal(unassociated_profile["stream"])
        end
        ::Katello::Pulp::Consumer.expects(:new).at_least_once.returns(mock_consumer)
        @host.expects(:import_package_profile).with do |packages|
          expected_packages = rpm_profiles.map { |prof| ::Katello::Pulp::SimplePackage.new(prof) }
          packages.map(&:nvra).must_equal(expected_packages.map(&:nvra))
        end
        @host.expects(:import_enabled_repositories).with(enabled_repos)
        @host.expects(:import_module_streams).with(modulemd_inventory_multiple)

        plan_action action, @host, profile1.to_json
        run_action action
      end

      it 'runs and no raised exception when pulp 404s on packages' do
        action = create_action action_class
        action.stubs(:action_subject).with(@host)

        ::Host.expects(:find_by).returns(@host).at_least_once
        mock_consumer = mock
        mock_consumer.expects(:upload_package_profile).raises(RestClient::ResourceNotFound)
        mock_consumer.expects(:upload_module_stream_profile)
        ::Katello::Pulp::Consumer.expects(:new).at_least_once.returns(mock_consumer)
        @host.expects(:import_package_profile).with(any_parameters).never
        @host.expects(:import_enabled_repositories).with(enabled_repos)
        @host.expects(:import_module_streams).with(modulemd_inventory)

        plan_action action, @host, profile.to_json
        run_action action
      end

      it 'runs and no raised exception when modulemd_inventory is empty' do
        action = create_action action_class
        action.stubs(:action_subject).with(@host)

        profile1 = [
          {"content_type" => "rpm", "profile" => rpm_profiles},
          {"content_type" => "enabled_repos", "profile" => enabled_repos},
          {"content_type" => "modulemd", "profile" => []}
        ]

        ::Host.expects(:find_by).returns(@host).at_least_once
        mock_consumer = mock
        mock_consumer.expects(:upload_package_profile).raises(RestClient::ResourceNotFound)
        ::Katello::Pulp::Consumer.expects(:new).at_least_once.returns(mock_consumer)
        @host.expects(:import_package_profile).with(any_parameters).never
        @host.expects(:import_enabled_repositories).with(enabled_repos)
        @host.expects(:import_module_streams).with([])

        plan_action action, @host, profile1.to_json
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
        mock_consumer.expects(:upload_module_stream_profile)
        ::Katello::Pulp::Consumer.expects(:new).at_least_once.returns(mock_consumer)
        @host.expects(:import_package_profile).with(any_parameters).raises(ActiveRecord::InvalidForeignKey)
        @host.expects(:import_enabled_repositories).with(enabled_repos)
        @host.expects(:import_module_streams).with(modulemd_inventory)
        plan_action action, @host, profile.to_json
        run_action action
      end

      describe "Debian Profile Upload" do
        let(:deb_package) { {"name" => "pi", "architecture" => "transcendent", "version" => "3.14159"} }
        let(:deb_package_profile) do
          {
            "deb_package_profile" => {
              "deb_packages" => [deb_package]
            }
          }
        end

        it 'plans' do
          action = create_action action_class
          action.stubs(:action_subject).with(@host)

          plan_action action, @host, deb_package_profile.to_json

          assert_action_planed_with action, Actions::Katello::Host::GenerateApplicability, [@host]
        end

        it 'runs' do
          action = create_action action_class
          action.stubs(:action_subject).with(@host)

          plan_action action, @host, deb_package_profile.to_json
          run_action action

          deb = @host.installed_debs.first

          assert_equal deb_package["name"], deb.name
          assert_equal deb_package["architecture"], deb.architecture
          assert_equal deb_package["version"], deb.version
          assert_equal 1, @host.installed_debs.size
        end

        it 'runs with new combined profile' do
          action = create_action action_class
          action.stubs(:action_subject).with(@host)

          deb_profile = [
            {"content_type" => "deb", "profile" => [deb_package]}
          ]

          plan_action action, @host, deb_profile.to_json
          run_action action

          deb = @host.installed_debs.first

          assert_equal deb_package["name"], deb.name
          assert_equal deb_package["architecture"], deb.architecture
          assert_equal deb_package["version"], deb.version
          assert_equal 1, @host.installed_debs.size
        end
      end
    end
  end
end
