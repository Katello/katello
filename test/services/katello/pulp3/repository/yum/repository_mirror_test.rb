require 'katello_test_helper'

module Katello
  module Service
    class Repository
      class YumRepositoryMirrorTest < ::ActiveSupport::TestCase
        include RepositorySupport

        def setup
          create(:smart_proxy, :default_smart_proxy, :with_pulp3)
          @mock_smart_proxy = mock('smart_proxy')
          @mock_smart_proxy.stubs(:pulp3_support?).returns(true)
          @mock_smart_proxy.stubs(:pulp2_preferred_for_type?).returns(false)
          @mock_smart_proxy.stubs(:pulp_master?).returns(false)
          @repo = FactoryBot.create(:katello_repository, :fedora_17_x86_64_dev, :with_product)
          @repo_service = @repo.backend_service(@mock_smart_proxy)
        end

        def test_feed_url
          pulp3_repo = Katello::Pulp3::Repository::Yum.new(@repo, @mock_smart_proxy)
          repo_mirror = pulp3_repo.with_mirror_adapter
          feed_url = URI(repo_mirror.remote_feed_url)

          assert_equal '/pulp/repos' + @repo.relative_path + '/', feed_url.path
        end
      end
    end
  end
end
