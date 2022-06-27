require 'katello_test_helper'

module Katello
  module Service
    class Repository
      class DistributionTest < ::ActiveSupport::TestCase
        def setup
          @mock_pulp3_api = mock('pulp3_api')
          @mock_smart_proxy = mock('smart_proxy')
          @mock_smart_proxy.stubs(:pulp3_support?).returns(true)
          @mock_smart_proxy.stubs(:pulp2_preferred_for_type?).returns(false)
          @mock_smart_proxy.stubs(:pulp_primary?).returns(true)
          @docker_repo = katello_repositories(:pulp3_docker_1)
          @docker_repo.stubs(:container_repository_name).returns("a repo name")
          @docker_repo_service = @docker_repo.backend_service(@mock_smart_proxy)
        end

        def test_distribution_options_path
          assert_equal @docker_repo_service.distribution_options(@docker_repo_service.relative_path)[:base_path], "a repo name"
        end

        def teardown
          mocha_teardown
        end
      end
    end
  end
end
