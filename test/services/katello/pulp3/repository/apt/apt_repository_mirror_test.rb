require 'katello_test_helper'
require 'support/pulp3_support'

module Katello
  module Service
    module Pulp3
      class AptRepositoryMirrorTest < ActiveSupport::TestCase
        include Katello::Pulp3Support

        def setup
          @primary = SmartProxy.pulp_primary
          @repo = katello_repositories(:pulp3_deb_1)
          @repo_service = ::Katello::Pulp3::Repository::Apt.new(@repo, @primary)
          @repo_mirror = ::Katello::Pulp3::RepositoryMirror.new(@repo_service)
          @mock_smart_proxy = mock('smart_proxy')
          @mock_smart_proxy.stubs(:pulp3_support?).returns(true)
          @mock_smart_proxy.stubs(:pulp2_preferred_for_type?).returns(false)
          @mock_smart_proxy.stubs(:pulp_primary?).returns(false)
        end

        def test_mirror_remote_download_policy_matches_proxy
          @mock_smart_proxy.stubs(:download_policy).returns("on_demand")
          pulp3_repo = Katello::Pulp3::Repository::Apt.new(@repo, @mock_smart_proxy)

          assert pulp3_repo.mirror_remote_options.key?(:policy)
          assert_equal "on_demand", pulp3_repo.mirror_remote_options[:policy]
        end

        def test_mirror_remote_download_policy_is_inherit_from_repository
          @mock_smart_proxy.stubs(:download_policy).returns(SmartProxy::DOWNLOAD_INHERIT)
          pulp3_repo = Katello::Pulp3::Repository::Apt.new(@repo, @mock_smart_proxy)

          assert_equal 'immediate', @repo.root.download_policy
          assert pulp3_repo.mirror_remote_options.key?(:policy)
          assert_equal "immediate", pulp3_repo.mirror_remote_options[:policy]
        end
      end
    end
  end
end
