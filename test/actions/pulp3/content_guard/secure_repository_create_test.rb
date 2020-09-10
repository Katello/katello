require 'katello_test_helper'

module ::Actions::Pulp3
  class SecureRepositoryCreateTest < ActiveSupport::TestCase
    include Katello::Pulp3Support
    CERT_FIXTURE = "#{Katello::Engine.root}/test/fixtures/certs/content_guard.crt".freeze
    def setup
      @primary = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
      @repo = katello_repositories(:generic_file)
      @repo.root.update(:url => 'http://test/test/', :unprotected => false)
    end

    def test_create
      content_guard = ::Katello::Pulp3::ContentGuard.first
      assert_nil content_guard
      create_repo(@repo, @primary)
      ForemanTasks.sync_task(
          ::Actions::Katello::Repository::MetadataGenerate, @repo)
      @repo.reload
      content_guard = ::Katello::Pulp3::ContentGuard.first
      assert content_guard
      distribution = Katello::Pulp3::DistributionReference.where(repository_id: @repo.id).first
      assert_equal content_guard.pulp_href, distribution.content_guard_href
    end
  end
end
