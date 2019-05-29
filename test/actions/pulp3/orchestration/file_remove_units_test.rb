require 'katello_test_helper'

module ::Actions::Pulp3
  class FileRemoveunitsTest < ActiveSupport::TestCase
    include Katello::Pulp3Support

    def setup
      @master = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
      @repo = katello_repositories(:pulp3_file_1)
      create_and_sync_repo(@repo, @master)
    end

    def create_and_sync_repo(repo, proxy)
      create_repo(repo, proxy)
      ForemanTasks.sync_task(
        ::Actions::Katello::Repository::MetadataGenerate, repo,
        repository_creation: true)
      sync_args = {:smart_proxy_id => proxy.id, :repo_id => repo.id}
      sync_action = ForemanTasks.sync_task(
        ::Actions::Pulp3::Orchestration::Repository::Sync, repo, proxy, sync_args)
      contents_changed = sync_action.output[:contents_changed]
      ForemanTasks.sync_task(
        ::Actions::Katello::Repository::IndexContent,
        id: repo.id, dependency: {},
        contents_changed: contents_changed,
        full_index: true)
    end

    def teardown
      ForemanTasks.sync_task(
          ::Actions::Pulp3::Orchestration::Repository::Delete, @repo, @master)
      @repo.reload
    end

    def test_remove_file_unit
      @repo.reload
      content_unit = @repo.repository_files.first
      refute_empty @repo.repository_files
      remove_content_args = {contents: [content_unit.id]}
      remove_action = ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::RemoveUnits, @repo, @master, remove_content_args)
      assert_equal "success", remove_action.result
    end

    def test_empty_content_args
      remove_content_args = {contents: []}
      remove_action = ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::RemoveUnits, @repo, @master, remove_content_args)
      assert_equal "success", remove_action.result
    end

    def test_incorrect_content_units
      remove_content_args = {contents: [ "not an id"]}
      assert_raises ForemanTasks::TaskError do
        ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::RemoveUnits, @repo, @master, remove_content_args)
      end
    end
  end
end
