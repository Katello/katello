require 'katello_test_helper'

module ::Actions::Pulp3
  class FileSyncTest < ActiveSupport::TestCase
    include Katello::Pulp3Support

    def setup
      @primary = SmartProxy.pulp_primary
      @repo = katello_repositories(:pulp3_file_1)
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

    def test_sync_with_pagination
      @repo.root.update(:url => "https://fixtures.pulpproject.org/file-many/", :mirroring_policy => ::Katello::RootRepository::MIRRORING_POLICY_ADDITIVE)
      ForemanTasks.sync_task(
          ::Actions::Pulp3::Orchestration::Repository::Update,
          @repo,
          @primary)

      old_page_size = Setting[:bulk_load_size]
      ::Setting[:bulk_load_size] = 10

      sync_args = {:smart_proxy_id => @primary.id, :repo_id => @repo.id}
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @primary, **sync_args)

      begin
        @repo.reload
        assert_equal 0, @repo.repository_file_units.count

        @repo.index_content
        assert_equal 250, @repo.repository_file_units.count
      ensure
        ::Setting[:bulk_load_size] = old_page_size
      end
    end

    def test_sync_with_mirror_false
      sync_args = {:smart_proxy_id => @primary.id, :repo_id => @repo.id}
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @primary, **sync_args)
      @repo.reload
      @repo.index_content
      pre_count_content = ::Katello::RepositoryFileUnit.where(:repository_id => @repo.id).count
      @repo.root.update(:url => "file:///var/lib/pulp/sync_imports/test_repos/file3", :mirroring_policy => ::Katello::RootRepository::MIRRORING_POLICY_ADDITIVE)

      ForemanTasks.sync_task(
          ::Actions::Pulp3::Orchestration::Repository::Update,
          @repo,
          @primary)

      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @primary, **sync_args)
      @repo.reload
      @repo.index_content
      post_count_content = ::Katello::RepositoryFileUnit.where(:repository_id => @repo.id).count
      assert_equal pre_count_content + 3, post_count_content
    end

    def test_sync_with_mirror_true
      sync_args = {:smart_proxy_id => @primary.id, :repo_id => @repo.id}
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @primary, **sync_args)
      @repo.reload
      @repo.index_content
      pre_count_content = ::Katello::RepositoryFileUnit.where(:repository_id => @repo.id).count
      @repo.root.update(:url => "file:///var/lib/pulp/sync_imports/test_repos/file2")

      ForemanTasks.sync_task(
          ::Actions::Pulp3::Orchestration::Repository::Update,
          @repo,
          @primary)

      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @primary, **sync_args)
      @repo.reload
      @repo.index_content
      post_count_content = ::Katello::RepositoryFileUnit.where(:repository_id => @repo.id).count
      assert_equal pre_count_content, post_count_content
    end
  end
end
