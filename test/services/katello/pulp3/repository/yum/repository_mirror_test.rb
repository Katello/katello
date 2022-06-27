require 'katello_test_helper'

module Katello
  module Service
    class Repository
      class YumRepositoryMirrorTest < ::ActiveSupport::TestCase
        def setup
          @mock_smart_proxy = mock('smart_proxy')
          @mock_smart_proxy.stubs(:pulp3_support?).returns(true)
          @mock_smart_proxy.stubs(:pulp2_preferred_for_type?).returns(false)
          @mock_smart_proxy.stubs(:pulp_primary?).returns(false)
          @repo = FactoryBot.create(:katello_repository, :fedora_17_x86_64_dev, :with_product)
          @repo_service = @repo.backend_service(@mock_smart_proxy)
        end

        def test_feed_url_is_prepended_with_pulp_rpm_content_path
          pulp3_repo = Katello::Pulp3::Repository::Yum.new(@repo, @mock_smart_proxy)

          assert_equal '/pulp/content' + @repo.relative_path + '/', pulp3_repo.partial_repo_path
        end

        def test_mirror_remote_download_policy_matches_proxy
          @mock_smart_proxy.stubs(:download_policy).returns("on_demand")
          pulp3_repo = Katello::Pulp3::Repository::Yum.new(@repo, @mock_smart_proxy)

          assert pulp3_repo.mirror_remote_options.key?(:policy)
          assert_equal "on_demand", pulp3_repo.mirror_remote_options[:policy]
        end

        def test_mirror_remote_download_policy_is_inherit_from_repository
          @mock_smart_proxy.stubs(:download_policy).returns(SmartProxy::DOWNLOAD_INHERIT)
          pulp3_repo = Katello::Pulp3::Repository::Yum.new(@repo, @mock_smart_proxy)

          assert_equal 'on_demand', @repo.root.download_policy
          assert pulp3_repo.mirror_remote_options.key?(:policy)
          assert_equal "on_demand", pulp3_repo.mirror_remote_options[:policy]
        end
      end
    end
  end
end
