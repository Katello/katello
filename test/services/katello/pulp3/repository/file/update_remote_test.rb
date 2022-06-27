require 'katello_test_helper'

module Katello
  module Service
    class Repository
      class UpdateRemoteTest < ::ActiveSupport::TestCase
        def setup
          mock_remotes_create_response = mock('response')
          mock_remotes_create_response.stubs(:pulp_href).returns('http://someurl')
          @mock_api_wrapper = mock("api_wrapper")
          @mock_pulp3_api = mock('pulp3_api')
          @mock_pulp3_api.stubs(:create).returns(mock_remotes_create_response)
          @mock_smart_proxy = mock('smart_proxy')
          @mock_smart_proxy.stubs(:pulp3_support?).returns(true)
          @mock_smart_proxy.stubs(:pulp2_preferred_for_type?).returns(false)
          @mock_smart_proxy.stubs(:pulp_primary?).returns(true)
          @file_repo = katello_repositories(:generic_file)
          @file_repo_service = @file_repo.backend_service(@mock_smart_proxy)
          @file_repo.root.update(url: 'my-files.org')
          @file_repo_service.stubs(:api).returns(@mock_api_wrapper)
          @mock_api_wrapper.stubs(:remotes_api).returns(@mock_pulp3_api)

          @file_repo.remote_href = '193874298udsfsdf'
          refute_empty @file_repo.remote_href
        end

        def test_feed_url_exists_and_remote_href_exists_updates_remote
          refute_empty @file_repo_service.common_remote_options[:url], "Feed url was empty or blank."
          @mock_pulp3_api.expects(:partial_update).once
          @file_repo_service.update_remote
        end

        def test_feed_url_is_missing_but_remote_href_exists_deletes_remote
          @file_repo_service.stubs(:remote_options).returns(url: '')
          assert_empty @file_repo_service.remote_options[:url], "Feed url was not empty or blank."
          @mock_pulp3_api.expects(:partial_update).never
          @mock_pulp3_api.expects(:delete).with(@file_repo.remote_href)
          @file_repo_service.update_remote
        end

        def test_feed_url_is_not_blank_and_remote_href_is_nil_creates_new_remote
          refute_empty @file_repo_service.remote_options[:url], "Feed url was empty or blank."
          @file_repo.remote_href = nil
          @mock_pulp3_api.expects(:partial_update).never
          @mock_pulp3_api.expects(:delete).never
          @file_repo_service.expects(:create_remote).once
          @file_repo_service.update_remote
        end

        def teardown
          mocha_teardown
        end
      end
    end
  end
end
