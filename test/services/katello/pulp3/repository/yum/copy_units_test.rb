require 'katello_test_helper'

module Katello
  module Service
    class Repository
      class YumCopyUnitsTest < ::ActiveSupport::TestCase
        include RepositorySupport

        def setup
          @mock_smart_proxy = mock('smart_proxy')
          @mock_smart_proxy.stubs(:pulp3_support?).returns(true)
          @mock_smart_proxy.stubs(:pulp2_preferred_for_type?).returns(false)
          @mock_smart_proxy.stubs(:pulp_master?).returns(true)
          @repo = katello_repositories(:fedora_17_x86_64_duplicate)
          @repo_service = @repo.backend_service(@mock_smart_proxy)
        end

        def test_copy_pulp_units_chooses_chunked_copy
          data = PulpRpmClient::Copy.new
          data.config = []

          content = []
          10_001.times do |i|
            content << i
          end

          data.config << { content: content }
          Katello::Pulp3::Repository::Yum.any_instance.expects(:copy_content_chunked).with(data).returns(true).once

          @repo_service.copy_pulp_units(data)
        end

        def test_copy_pulp_units_chooses_single_copy
          data = PulpRpmClient::Copy.new
          data.config = []

          content = []
          3.times do |i|
            content << i
          end

          data.config << { content: content }
          mock_api = "test"
          Katello::Pulp3::Api::Yum.any_instance.expects(:copy_api).returns(mock_api).once
          mock_api.stubs(:copy_content).with(data).returns("copied")

          @repo_service.copy_pulp_units(data)
        end

        def test_copy_content_chunked_limits_units_copied
          data = PulpRpmClient::Copy.new
          data.config = []

          content = []
          30_001.times do |i|
            content << i
          end

          3.times { data.config << { content: content } }

          mock_api = "test"
          Katello::Pulp3::Api::Yum.any_instance.expects(:copy_api).returns(mock_api).times(10)
          mock_api.stubs(:copy_content).returns("copied")

          @repo_service.copy_content_chunked(data)
        end
      end
    end
  end
end
