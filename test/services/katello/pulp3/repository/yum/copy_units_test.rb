require 'katello_test_helper'

module Katello
  module Service
    class Repository
      class YumCopyUnitsTest < ::ActiveSupport::TestCase
        def setup
          @mock_smart_proxy = mock('smart_proxy')
          @mock_smart_proxy.stubs(:pulp3_support?).returns(true)
          @mock_smart_proxy.stubs(:pulp2_preferred_for_type?).returns(false)
          @repo = katello_repositories(:fedora_17_x86_64_duplicate)
          @repo_service = @repo.backend_service(@mock_smart_proxy)
        end

        def test_copy_api_data_dup_does_deep_copy
          data = PulpRpmClient::Copy.new
          data.config = [
            { source_repo_version: "a source repo",
              dest_repo: "a dest repo",
              content: ["1", "2", "3"],
              dest_base_version: 0 },
            { source_repo_version: "another source repo",
              dest_repo: "another dest repo",
              content: ["4", "5", "6"],
              dest_base_version: 1 }
          ]
          data.dependency_solving = false

          data_dup = @repo_service.copy_api_data_dup(data)

          refute data.equal?(data_dup)
        end

        def test_copy_api_data_dup_clears_content
          data = PulpRpmClient::Copy.new
          data.config = [
            { source_repo_version: "a source repo",
              dest_repo: "a dest repo",
              content: ["1", "2", "3"],
              dest_base_version: 0 },
            { source_repo_version: "another source repo",
              dest_repo: "another dest repo",
              content: ["4", "5", "6"],
              dest_base_version: 1 }
          ]
          data.dependency_solving = false

          data.config.first[:content] = []
          data.config.second[:content] = []

          data_dup = @repo_service.copy_api_data_dup(data)

          assert_equal data, data_dup
        end

        def test_copy_content_chunked_limits_units_copied
          data = PulpRpmClient::Copy.new
          data.config = []

          content = []
          30_001.times { |i| content << i }

          3.times { data.config << { content: content } }

          mock_api = "test"
          Katello::Pulp3::Api::Yum.any_instance.expects(:copy_api).returns(mock_api).times(12)
          mock_api.stubs(:copy_content).returns("copied")

          @repo_service.copy_content_chunked(data)
        end

        def test_copy_content_chunked_copies_correct_units
          data = PulpRpmClient::Copy.new
          data.config = []

          mock_api = "test"
          Katello::Pulp3::Api::Yum.any_instance.expects(:copy_api).returns(mock_api).times(4)

          3.times do
            data.config << {
              source_repo_version: "repo version",
              dest_repo: "dest repo",
              content: []
            }
          end
          data.config[0][:content] = (0..9_999).to_a
          data.config[1][:content] = (10_000..19_999).to_a
          data.config[2][:content] = (20_000..30_000).to_a

          mock_api.expects(:copy_content).returns("task").once.with do |value|
            value.config == [{source_repo_version: "repo version", dest_repo: "dest repo", content: (0..9_999).to_a},
                             {source_repo_version: "repo version", dest_repo: "dest repo", content: []},
                             {source_repo_version: "repo version", dest_repo: "dest repo", content: []}]
          end

          mock_api.expects(:copy_content).returns("task").once.with do |value|
            value.config == [{source_repo_version: "repo version", dest_repo: "dest repo", content: []},
                             {source_repo_version: "repo version", dest_repo: "dest repo", content: (10_000..19_999).to_a},
                             {source_repo_version: "repo version", dest_repo: "dest repo", content: []}]
          end

          mock_api.expects(:copy_content).returns("task").once.with do |value|
            value.config == [{source_repo_version: "repo version", dest_repo: "dest repo", content: []},
                             {source_repo_version: "repo version", dest_repo: "dest repo", content: []},
                             {source_repo_version: "repo version", dest_repo: "dest repo", content: (20_001..30_000).to_a}]
          end

          mock_api.expects(:copy_content).returns("task").once.with do |value|
            value.config == [{source_repo_version: "repo version", dest_repo: "dest repo", content: []},
                             {source_repo_version: "repo version", dest_repo: "dest repo", content: []},
                             {source_repo_version: "repo version", dest_repo: "dest repo", content: [20_000]}]
          end

          @repo_service.copy_content_chunked(data)
        end
      end
    end
  end
end
