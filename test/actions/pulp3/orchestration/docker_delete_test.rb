require 'katello_test_helper'

module ::Actions::Pulp3
  class DockerDeleteTest < ActiveSupport::TestCase
    include ::Katello::Pulp3Support

    def setup
      @primary = SmartProxy.pulp_primary
      @repo = katello_repositories(:busybox)
      ensure_creatable(@repo, @primary)
      create_repo(@repo, @primary)
      @repo.root.update(include_tags: ['latest'])
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
  end
end
