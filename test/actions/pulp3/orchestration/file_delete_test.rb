require 'katello_test_helper'

module ::Actions::Pulp3
  class FileDeleteTest < ActiveSupport::TestCase
    include ::Katello::Pulp3Support

    def setup
      @primary = SmartProxy.pulp_primary
      @repo = katello_repositories(:generic_file)
      @repo.root.update(:url => 'http://test/test/', :unprotected => true)
      create_repo(@repo, @primary)
      ForemanTasks.sync_task(
        ::Actions::Katello::Repository::MetadataGenerate, @repo)

      assert Katello::Pulp3::RepositoryReference.find_by(
        :root_repository_id => @repo.root.id,
        :content_view_id => @repo.content_view.id)

      refute_empty Katello::Pulp3::DistributionReference.where(repository_id: @repo.id)
    end

    def teardown
      ForemanTasks.sync_task(
        ::Actions::Pulp3::Orchestration::Repository::Delete, @repo, @primary)
      @repo.reload
    end

    def test_repository_reference_is_deleted
      ForemanTasks.sync_task(
          ::Actions::Pulp3::Orchestration::Repository::Delete, @repo, @primary)
      @repo.reload
      repo_reference = Katello::Pulp3::RepositoryReference.find_by(
        :root_repository_id => @repo.root.id,
        :content_view_id => @repo.content_view.id)

      assert_nil repo_reference
    end

    def test_distribution_references_are_deleted
      ForemanTasks.sync_task(
          ::Actions::Pulp3::Orchestration::Repository::Delete, @repo, @primary)
      @repo.reload
      distribution_references = Katello::Pulp3::DistributionReference.where(repository_id: @repo.id)

      assert_empty distribution_references
    end

    def test_delete_deleted_distribution_references
      ForemanTasks.sync_task(
          ::Actions::Pulp3::Repository::DeleteDistributions, @repo.id, @primary)

      assert_empty Katello::Pulp3::DistributionReference.where(repository_id: @repo.id)

      ForemanTasks.sync_task(
          ::Actions::Pulp3::Repository::DeleteDistributions, @repo.id, @primary)
      assert_empty Katello::Pulp3::DistributionReference.where(repository_id: @repo.id)

      repo_reference = Katello::Pulp3::RepositoryReference.find_by(
          :root_repository_id => @repo.root.id,
          :content_view_id => @repo.content_view.id)

      refute_nil repo_reference

      ForemanTasks.sync_task(
          ::Actions::Pulp3::Orchestration::Repository::Delete, @repo, @primary)
      @repo.reload

      repo_reference = Katello::Pulp3::RepositoryReference.find_by(
          :root_repository_id => @repo.root.id,
          :content_view_id => @repo.content_view.id)

      assert_nil repo_reference
    end

    def test_delete_deleted_remote_references
      ForemanTasks.sync_task(
          ::Actions::Pulp3::Repository::DeleteRemote, @repo.id, @primary)

      repo_reference = Katello::Pulp3::RepositoryReference.find_by(
          :root_repository_id => @repo.root.id,
          :content_view_id => @repo.content_view.id)
      refute_nil repo_reference

      ForemanTasks.sync_task(
          ::Actions::Pulp3::Orchestration::Repository::Delete, @repo, @primary)
      @repo.reload

      repo_reference = Katello::Pulp3::RepositoryReference.find_by(
          :root_repository_id => @repo.root.id,
          :content_view_id => @repo.content_view.id)

      assert_nil repo_reference
    end
  end
end
