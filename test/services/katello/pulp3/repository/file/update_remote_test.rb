require 'katello_test_helper'

module Katello
  module Service
    class Repository
      class UpdateRemoteTest < ::ActiveSupport::TestCase
        include RepositorySupport

        def setup
          @mock_pulp3_api = mock('pulp3_api')

          @mock_smart_proxy = mock('smart_proxy')
          @mock_smart_proxy.stubs(:pulp3_support?).returns(true)
          @mock_smart_proxy.stubs(:pulp3_api).returns(@mock_pulp3_api)
          @mock_smart_proxy.stubs(:remote_file_file_partial_update).returns(false)
          @file_repo = katello_repositories(:generic_file)
          @file_repo_service = @file_repo.backend_service(@mock_smart_proxy)
          @file_repo.root.update_attributes(url: 'my-files.org')

          @file_repo.remote_href = '193874298udsfsdf'
          refute_empty @file_repo.remote_href
        end

        def test_feed_url_exists
          refute_empty @file_repo_service.common_remote_options[:url], "Feed url was empty or blank."
          @mock_pulp3_api.expects(:remotes_file_file_partial_update).once
          @file_repo_service.update_remote
        end

        def test_feed_url_is_missing
          @file_repo_service.stubs(:remote_options).returns(url: '')
          assert_empty @file_repo_service.remote_options[:url], "Feed url was not empty or blank."
          @mock_pulp3_api.expects(:remotes_file_file_partial_update).never
          @file_repo_service.update_remote
        end

        def teardown
          mocha_teardown
        end
      end
    end
  end
end
