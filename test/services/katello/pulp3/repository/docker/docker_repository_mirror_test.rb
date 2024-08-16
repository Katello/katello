require 'katello_test_helper'
require 'support/pulp3_support'

module Katello
  module Service
    module Pulp3
      class DockerRepositoryMirrorTest < ActiveSupport::TestCase
        include Katello::Pulp3Support

        def setup
          @primary = SmartProxy.pulp_primary
          @repo = katello_repositories(:pulp3_docker_1)
          @repo_service = ::Katello::Pulp3::Repository::Docker.new(@repo, @primary)
          @repo_mirror = ::Katello::Pulp3::RepositoryMirror.new(@repo_service)
          @mock_smart_proxy = mock('smart_proxy')
          @mock_smart_proxy.stubs(:pulp3_support?).returns(true)
          @mock_smart_proxy.stubs(:pulp2_preferred_for_type?).returns(false)
          @mock_smart_proxy.stubs(:pulp_primary?).returns(false)
        end

        def test_sync
          @repo_mirror.stubs(:remote_href).returns("remote_href")
          @repo_mirror.stubs(:repository_href).returns("repository_href")
          sync_url = @repo_service.api.repository_sync_url_class.new(remote: "remote_href", mirror: true)
          PulpContainerClient::ContainerRepositorySyncURL.expects(:new).with({ remote: "remote_href", mirror: true }).once.returns(sync_url)
          PulpContainerClient::RepositoriesContainerApi.any_instance.expects(:sync).once.with("repository_href", sync_url)
          @repo_mirror.sync(optimize: "test", skip_types: "another test")
        end

        def test_refresh_distributions_update_dist
          mock_distribution = "distro"
          mock_distribution.expects(:pulp_href).once.returns("pulp_href")
          @repo_mirror.stubs(:version_href).returns("repo_href")
          @repo_service.expects(:lookup_distributions).returns([mock_distribution])
          @repo_service.expects(:relative_path).returns("base_path")
          PulpContainerClient::DistributionsContainerApi.any_instance.expects(:partial_update).with("pulp_href",
                                                                                                    { repository_version: 'repo_href',
                                                                                                      base_path: "base_path" })
          @repo_mirror.refresh_distributions(name: "test name", base_path: "test base_path", content_guard: "test content_guard")
        end

        def test_refresh_distributions_create_dist
          @repo_service.stubs(:lookup_distributions).returns([])
          @repo_service.stubs(:relative_path).returns("mock relative_path")
          @repo_mirror.stubs(:version_href).returns("repo_href")
          distribution_data = "mock distribution_data"
          PulpContainerClient::ContainerContainerDistribution.expects(:new).with(
          {
            :base_path => "mock relative_path",
            :name => "Default_Organization-Cabinet-pulp3_Docker_1",
            :repository_version => "repo_href",
          }).returns(distribution_data)
          PulpContainerClient::DistributionsContainerApi.any_instance.expects(:create).with(distribution_data)
          @repo_mirror.refresh_distributions(name: "test name", base_path: "test base_path", content_guard: "test content_guard")
        end

        def test_mirror_remote_download_policy_matches_proxy
          @mock_smart_proxy.stubs(:download_policy).returns("on_demand")
          pulp3_repo = Katello::Pulp3::Repository::Docker.new(@repo, @mock_smart_proxy)

          assert pulp3_repo.mirror_remote_options.key?(:policy)
          assert_equal "on_demand", pulp3_repo.mirror_remote_options[:policy]
        end

        def test_mirror_remote_download_policy_is_inherit_from_repository
          @mock_smart_proxy.stubs(:download_policy).returns(SmartProxy::DOWNLOAD_INHERIT)
          pulp3_repo = Katello::Pulp3::Repository::Docker.new(@repo, @mock_smart_proxy)

          assert_equal 'immediate', @repo.root.download_policy
          assert pulp3_repo.mirror_remote_options.key?(:policy)
          assert_equal "immediate", pulp3_repo.mirror_remote_options[:policy]
        end
      end
    end
  end
end
