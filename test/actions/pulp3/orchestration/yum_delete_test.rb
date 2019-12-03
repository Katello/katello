require 'katello_test_helper'

module ::Actions::Pulp3
  class YumDeleteTest < ActiveSupport::TestCase
    include ::Katello::Pulp3Support

    def setup
      @master = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
      @repo = katello_repositories(:fedora_17_x86_64_duplicate)
      create_repo(@repo, @master)
      ForemanTasks.sync_task(
        ::Actions::Katello::Repository::MetadataGenerate, @repo)

      assert Katello::Pulp3::RepositoryReference.find_by(
        :root_repository_id => @repo.root.id,
        :content_view_id => @repo.content_view.id)

      refute_empty Katello::Pulp3::DistributionReference.where(repository_id: @repo.id)

      ForemanTasks.sync_task(
        ::Actions::Pulp3::Orchestration::Repository::Delete, @repo, @master)
      @repo.reload
    end

    def test_repository_reference_is_deleted
      repo_reference = Katello::Pulp3::RepositoryReference.find_by(
        :root_repository_id => @repo.root.id,
        :content_view_id => @repo.content_view.id)

      assert_nil repo_reference
    end

    def test_distribution_references_are_deleted
      distribution_references = Katello::Pulp3::DistributionReference.where(repository_id: @repo.id)

      assert_empty distribution_references
    end
  end
end
