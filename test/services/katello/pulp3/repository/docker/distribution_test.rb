require 'katello_test_helper'

module Katello
  module Service
    class Repository
      class DistributionTest < ::ActiveSupport::TestCase
        include Katello::Pulp3Support

        def setup
          @mock_pulp3_api = mock('pulp3_api')
          @mock_smart_proxy = mock('smart_proxy')
          @mock_smart_proxy.stubs(:pulp3_support?).returns(true)
          @mock_smart_proxy.stubs(:pulp2_preferred_for_type?).returns(false)
          @mock_smart_proxy.stubs(:pulp_primary?).returns(true)
          @docker_repo = katello_repositories(:pulp3_docker_1)
          @docker_repo.stubs(:container_repository_name).returns("a repo name")
        end

        def test_distribution_options_path
          docker_repo_service = @docker_repo.backend_service(@mock_smart_proxy)

          assert_equal docker_repo_service.distribution_options(docker_repo_service.relative_path)[:base_path], "a repo name"
        end

        def test_push_distribution_tracks_repository_instead_of_fixed_version
          @docker_repo.root.stubs(:is_container_push).returns(true)
          @docker_repo.stubs(:in_default_view?).returns(true)
          service = @docker_repo.backend_service(@mock_smart_proxy)
          service.stubs(:repository_reference).returns(stub(repository_href: '/pulp/api/v3/repositories/container/container/repo/'))

          options = service.distribution_options('org/product/image')

          assert_equal '/pulp/api/v3/repositories/container/container/repo/', options[:repository]
          refute options.key?(:repository_version)
        end

        def test_promoted_push_distribution_serves_fixed_version
          @docker_repo.root.stubs(:is_container_push).returns(true)
          @docker_repo.stubs(:in_default_view?).returns(false)
          @docker_repo.stubs(:version_href).returns('/pulp/api/v3/repositories/container/container/repo/versions/1/')
          service = @docker_repo.backend_service(@mock_smart_proxy)

          options = service.distribution_options('promoted/image')

          assert_equal @docker_repo.version_href, options[:repository_version]
          refute options.key?(:repository)
        end

        def test_instance_for_type_loads_type_missing_from_cache
          repository_type_manager = ::Katello::RepositoryTypeManager
          original_repository_types = repository_type_manager.enabled_repository_types(false)
          partial_repository_types = {
            'yum' => repository_type_manager.find_defined('yum'),
          }
          repository_type_manager.instance_variable_set(:@enabled_repository_types, partial_repository_types)

          assert_instance_of ::Katello::Pulp3::Repository::Docker, @docker_repo.backend_service(@mock_smart_proxy)
        ensure
          repository_type_manager.instance_variable_set(:@enabled_repository_types, original_repository_types)
        end

        def teardown
          mocha_teardown
        end
      end
    end
  end
end
