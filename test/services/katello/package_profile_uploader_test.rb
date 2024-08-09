require 'katello_test_helper'

module Katello
  class PackageProfileUploaderTest < ActiveSupport::TestCase
    describe 'Katello::Host::PackageProfileUploader' do
      let(:host) do
        FactoryBot.create(
          :host,
          :with_content,
          :with_subscription,
          content_view: katello_content_views(:library_dev_view),
          lifecycle_environment: katello_environments(:library),
          id: 343
        )
      end
      let(:rpm_profiles) { [{"name" => "foo", "version" => "1", "release" => "3"}] }
      let(:enabled_repos) { [{"repositoryid" => "foo", "baseurl" => "http://foo.com"}] }
      let(:modulemd_inventory) do
        [{"name" => "foo", "stream" => "1.1", "arch" => "x86_64",
          "context" => "cccc", "version" => "11111", "status" => "enabled"}]
      end
      let(:profile) do
        [
          {"content_type" => "rpm", "name" => "rpm", "profile" => rpm_profiles},
          {"content_type" => "enabled_repos", "name" => "enabled_repos", "profile" => enabled_repos},
          {"content_type" => "modulemd", "name" => "modulemd", "profile" => modulemd_inventory},
        ]
      end
      let(:profile_string) { profile.to_json }
      let(:subject) do
        ::Katello::Host::PackageProfileUploader.new(
          profile_string: profile_string,
          host: host
        )
      end

      def test_upload
        subject.expects(:import_package_profile)
          .with(profile)

        subject.upload
      end

      def test_import_package_profile
        ::Katello::Host::PackageProfileUploader.expects(:import_package_profile_for_host)
          .with(host.id, profile)

        subject.import_package_profile(profile)
      end

      def test_import_package_profile_for_host
        ::Host.expects(:find_by).with(id: host.id).returns(host)
        host.expects(:import_package_profile).at_least_once

        subject.class.import_package_profile_for_host(host.id, profile)
      end

      def test_trigger_applicability_generation
        ::Katello::Host::ContentFacet.expects(
          :trigger_applicability_generation
        ).with(host.id)

        subject.trigger_applicability_generation
      end
    end
  end
end
