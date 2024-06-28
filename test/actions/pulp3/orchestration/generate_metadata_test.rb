require 'katello_test_helper'

module ::Actions::Pulp3
  class GenerateMetadataTest < ActiveSupport::TestCase
    include Katello::Pulp3Support
    include Support::CapsuleSupport

    def setup
      @primary = SmartProxy.pulp_primary
      @repo = katello_repositories(:generic_file)
      @repo.root.update(:url => 'http://test/test/')
      ensure_creatable(@repo, @primary)
      create_repo(@repo, @primary)
    end

    def teardown
      ForemanTasks.sync_task(
          ::Actions::Pulp3::Orchestration::Repository::Delete, @repo, @primary)
      @repo.reload
    end

    def test_generate_metadata
      assert @repo.version_href

      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::GenerateMetadata, @repo, @primary)
      @repo.reload

      assert @repo.publication_href
    end

    def test_generate_with_source_repo
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::GenerateMetadata, @repo, @primary)
      @repo.reload
      @clone = katello_repositories(:generic_file_dev)
      assert_equal 1, Katello::Pulp3::DistributionReference.where(repository_id: @repo.id).count
      ensure_creatable(@clone, @primary)
      @clone.create_smart_proxy_sync_history(proxy_with_pulp)
      assert_equal @clone.smart_proxy_sync_histories.count, 1
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::GenerateMetadata, @clone, @primary, source_repository: @repo)
      assert_equal @repo.publication_href, @clone.reload.publication_href
      assert_equal 1, Katello::Pulp3::DistributionReference.where(repository_id: @clone.id).count
      assert_equal @clone.smart_proxy_sync_histories.count, 0
      ForemanTasks.sync_task(
        ::Actions::Pulp3::Orchestration::Repository::Delete, @clone, @primary)
    end

    def test_generate_with_sha1_root_repo_checksum
      root = @repo.root
      root.checksum_type = 'sha1'
      root.save!(validate: false)
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::GenerateMetadata, @repo, @primary, force_publication: true)
      root.reload
      assert_nil root.checksum_type
    end
  end
end
