require 'katello_test_helper'

module ::Actions::Pulp3
  class FileRemoveunitsTest < ActiveSupport::TestCase
    include Katello::Pulp3Support

    def setup
      @primary = SmartProxy.pulp_primary
      @repo = katello_repositories(:pulp3_file_1)
      create_and_sync_repo(@repo, @primary)
      @repo.reload
    end

    def create_and_sync_repo(repo, proxy)
      create_repo(repo, proxy)
      ForemanTasks.sync_task(
        ::Actions::Katello::Repository::MetadataGenerate, repo)
      sync_args = {:smart_proxy_id => proxy.id, :repo_id => repo.id}
      sync_action = ForemanTasks.sync_task(
        ::Actions::Pulp3::Orchestration::Repository::Sync, repo, proxy, **sync_args)
      contents_changed = sync_action.output[:contents_changed]
      ForemanTasks.sync_task(
        ::Actions::Katello::Repository::IndexContent,
        id: repo.id, dependency: {},
        contents_changed: contents_changed,
        full_index: true)
    end

    def teardown
      ForemanTasks.sync_task(
          ::Actions::Pulp3::Orchestration::Repository::Delete, @repo, @primary)
      @repo.reload
    end

    def test_remove_file_unit
      content_unit = @repo.files.first
      refute_empty @repo.files

      remove_content_args = {contents: [content_unit.id], content_unit_type: 'file'}
      remove_action = ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::RemoveUnits, @repo, @primary, remove_content_args)
      assert_equal "success", remove_action.result
    end

    def test_remove_file_unit_updates_version_href
      content_unit = @repo.files.first
      refute_empty @repo.files

      version_href = @repo.version_href
      remove_content_args = {contents: [content_unit.id], content_unit_type: 'file'}
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::RemoveUnits, @repo, @primary, remove_content_args)
      refute_equal version_href, @repo.reload.version_href
    end

    def test_empty_content_args_doesnt_update_version_href
      version_href = @repo.reload.version_href
      remove_content_args = {contents: [], content_unit_type: 'file'}
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::RemoveUnits, @repo, @primary, remove_content_args)
      assert_equal version_href, @repo.reload.version_href
    end

    def test_empty_content_args
      remove_content_args = {contents: [], content_unit_type: 'file'}
      remove_action = ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::RemoveUnits, @repo, @primary, remove_content_args)
      assert_equal "success", remove_action.result
    end

    def test_incorrect_content_units_doesnt_update_version_href
      version_href = @repo.reload.version_href
      remove_content_args = {contents: [ "not an id"], content_unit_type: 'file'}
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::RemoveUnits, @repo, @primary, remove_content_args)
      assert_equal version_href, @repo.reload.version_href
    end
  end
end
