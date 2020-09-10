require 'katello_test_helper'

module ::Actions::Pulp3
  class GenerateMetadataTest < ActiveSupport::TestCase
    include Katello::Pulp3Support

    def setup
      @primary = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
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
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::GenerateMetadata, @clone, @primary, source_repository: @repo)
      assert_equal @repo.publication_href, @clone.reload.publication_href
      assert_equal 1, Katello::Pulp3::DistributionReference.where(repository_id: @clone.id).count
    end
  end
end
