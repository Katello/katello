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
      @mock_smart_proxy = mock
      @mock_smart_proxy.stubs(:has_feature?).with(::SmartProxy::PULP_FEATURE).returns(true)
      ::SmartProxy.stubs(:pulp_primary).returns(@mock_smart_proxy)
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
      end

      it 'runs and no raised exception if host not found' do
        action = create_action action_class
        action.stubs(:action_subject).with(@host)

        ::Host.expects(:find_by).returns(nil)

        plan_action action, @host, profile.to_json
        run_action action
      end

      it 'runs and no raised exception if host sub facet not found' do
        action = create_action action_class
        action.stubs(:action_subject).with(@host)

        ::Host.expects(:find_by).twice.returns(@host).at_least_once
        @host.expects(:content_facet).returns(nil)

        plan_action action, @host, profile.to_json
        run_action action
      end

      it 'runs and skips Pulp::Consumer with pulp2 is not present' do
        action = create_action action_class
        action.stubs(:action_subject).with(@host)

        @mock_smart_proxy.stubs(:has_feature?).with(::SmartProxy::PULP_FEATURE).returns(false)
        ::Host.expects(:find_by).returns(@host).at_least_once
        @host.expects(:import_package_profile).with do |packages|
          expected_packages = rpm_profiles.map { |prof| ::Katello::Pulp::SimplePackage.new(prof) }
          _(packages.map(&:nvra)).must_equal(expected_packages.map(&:nvra))
        end
        @host.expects(:import_enabled_repositories).with(enabled_repos)

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
