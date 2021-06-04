require 'katello_test_helper'

module ::Actions::Pulp3
  class AnsibleCollectionDeleteTest < ActiveSupport::TestCase
    include ::Katello::Pulp3Support

    def setup
      @primary = SmartProxy.pulp_primary
      @repo = katello_repositories(:pulp3_ansible_collection_1)
      ensure_creatable(@repo, @primary)
      create_repo(@repo, @primary)
      ForemanTasks.sync_task(
          ::Actions::Katello::Repository::MetadataGenerate, @repo)

      assert Katello::Pulp3::RepositoryReference.find_by(
          :root_repository_id => @repo.root.id,
          :content_view_id => @repo.content_view.id)

      refute_empty Katello::Pulp3::DistributionReference.where(repository_id: @repo.id)

      ForemanTasks.sync_task(
          ::Actions::Pulp3::Orchestration::Repository::Delete, @repo, @primary)
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
