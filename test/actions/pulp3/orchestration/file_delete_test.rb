require 'katello_test_helper'

module ::Actions::Pulp3
  class FileDeleteTest < ActiveSupport::TestCase
    include ::Katello::Pulp3Support

    def setup
      @master = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
      @repo = katello_repositories(:generic_file)
      @repo.root.update_attributes(:url => 'http://test/test/')
      create_repo(@repo, @master)
      ForemanTasks.sync_task(
        ::Actions::Katello::Repository::MetadataGenerate, @repo,
        repository_creation: true)

      assert Katello::Pulp3::RepositoryReference.find_by(
        :root_repository_id => @repo.root.id,
        :content_view_id => @repo.content_view.id)

      refute_empty Katello::Pulp3::DistributionReference.where(
        root_repository_id: @repo.root.id)

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
      distribution_references = Katello::Pulp3::DistributionReference.where(
        root_repository_id: @repo.root.id)

      assert_empty distribution_references
    end
  end
end
