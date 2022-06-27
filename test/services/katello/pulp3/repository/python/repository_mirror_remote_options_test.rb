require 'katello_test_helper'

module Katello
  module Service
    class Repository
      class PythonRepositoryMirrorOptionsTest < ::ActiveSupport::TestCase
        def setup
          @mock_smart_proxy = mock('smart_proxy')
          @mock_smart_proxy.stubs(:pulp3_support?).returns(true)
          @mock_smart_proxy.stubs(:pulp2_preferred_for_type?).returns(false)
          @mock_smart_proxy.stubs(:pulp_primary?).returns(false)
          @repo = katello_repositories(:pulp3_python_1)
          @repo_service = @repo.backend_service(@mock_smart_proxy)
        end

        def test_remote_options
          @mock_smart_proxy.stubs(:download_policy).returns(SmartProxy::DOWNLOAD_INHERIT)
          pulp3_repo = @repo.repository_type.pulp3_service_class.new(@repo, @mock_smart_proxy)
          Katello::Pulp3::RepositoryMirror.any_instance.expects(:ssl_remote_options).at_least_once.returns({})
          assert_equal "Default_Organization-Cabinet-pulp3_Python_1", pulp3_repo.with_mirror_adapter.remote_options[:name]
          assert pulp3_repo.with_mirror_adapter.remote_options[:url].end_with?(pulp3_repo.partial_repo_path)
        end
      end
    end
  end
end
