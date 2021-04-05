require 'katello_test_helper'
require 'support/pulp3_support'

module Katello
  module Service
    module Pulp3
      class AnsibleCollectionRepositoryMirrorTest < ActiveSupport::TestCase
        include Katello::Pulp3Support

        def setup
          @primary = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
          @repo = katello_repositories(:pulp3_ansible_collection_1)
          @repo_service = ::Katello::Pulp3::Repository::AnsibleCollection.new(@repo, @primary)
          @repo_mirror = ::Katello::Pulp3::RepositoryMirror.new(@repo_service)
        end

        def test_sync
          @repo_mirror.stubs(:remote_href).returns("remote_href")
          @repo_mirror.stubs(:repository_href).returns("repository_href")
          sync_url = @repo_service.api.class.repository_sync_url_class.new(remote: "remote_href", mirror: true)
          PulpAnsibleClient::AnsibleRepositorySyncURL.expects(:new).with(remote: "remote_href", mirror: true).once.returns(sync_url)
          PulpAnsibleClient::RepositoriesAnsibleApi.any_instance.expects(:sync).once.with("repository_href", sync_url)
          @repo_mirror.sync(optimize: "test", skip_types: "another test")
        end

        def test_refresh_distributions_update_dist
          mock_distribution = "distro"
          mock_distribution.expects(:pulp_href).once.returns("pulp_href")
          @repo_service.stubs(:lookup_distributions).returns([mock_distribution])
          PulpAnsibleClient::DistributionsAnsibleApi.any_instance.expects(:partial_update).with("pulp_href", {:content_guard => nil})
          @repo_mirror.refresh_distributions(name: "test name", base_path: "test base_path", content_guard: "test content_guard")
        end

        def test_refresh_distributions_create_dist
          @repo_service.stubs(:lookup_distributions).returns([])
          @repo_service.stubs(:relative_path).returns("mock relative_path")
          distribution_data = "mock distribution_data"
          PulpAnsibleClient::AnsibleAnsibleDistribution.expects(:new).with(
          {
            :base_path => "mock relative_path",
            :name => "Default_Organization-Cabinet-pulp3_Ansible_collection_1",
            :content_guard => nil
          }).returns(distribution_data)

          PulpAnsibleClient::DistributionsAnsibleApi.any_instance.expects(:create).with(distribution_data)
          @repo_mirror.refresh_distributions(name: "test name", base_path: "test base_path", content_guard: "test content_guard")
        end
      end
    end
  end
end
