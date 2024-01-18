require 'katello_test_helper'

module ::Actions::Pulp3
  class DockerSyncTest < ActiveSupport::TestCase
    include Katello::Pulp3Support

    def setup
      @primary = SmartProxy.pulp_primary
      @repo = katello_repositories(:busybox)
      create_repo(@repo, @primary)
      ForemanTasks.sync_task(
          ::Actions::Katello::Repository::MetadataGenerate, @repo)

      repository_reference = Katello::Pulp3::RepositoryReference.find_by(
          :root_repository_id => @repo.root.id,
          :content_view_id => @repo.content_view.id)

      assert repository_reference
      refute_empty repository_reference.repository_href
      refute_empty Katello::Pulp3::DistributionReference.where(repository_id: @repo.id)
      @repo_version_href = @repo.version_href
    end

    def teardown
      ForemanTasks.sync_task(
          ::Actions::Pulp3::Orchestration::Repository::Delete, @repo, @primary)
      @repo.reload
    end

    def test_sync
      sync_args = {:smart_proxy_id => @primary.id, :repo_id => @repo.id}
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @primary, **sync_args)
      @repo.reload
      refute_equal @repo.version_href, @repo_version_href
      repository_reference = Katello::Pulp3::RepositoryReference.find_by(
          :root_repository_id => @repo.root.id,
          :content_view_id => @repo.content_view.id)

      assert_equal repository_reference.repository_href + "versions/1/", @repo.version_href
    end
  end
end
