require 'katello_test_helper'

module ::Actions::Katello::Repository
  class IndexContentTest < ActiveSupport::TestCase
    include Katello::Pulp3Support

    def setup
      @now = DateTime.current
      @primary = SmartProxy.pulp_primary
      @repo = katello_repositories(:fedora_17_x86_64_duplicate)
      @repo.update(last_contents_changed: @now - 600.seconds)
    end

    def test_index_not_performed_if_last_contents_changed_older_than_last_indexed
      @repo.update(last_indexed: (@now - 300.seconds).to_datetime)
      indexed_time = @repo.last_indexed

      task = ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, id: @repo.id)

      @repo.reload
      assert_equal indexed_time.strftime("%D-%T"), @repo.last_indexed.strftime("%D-%T")
      assert task.output[:index_skipped]
    end

    def test_index_performed_if_forced_despite_last_indexed_time
      @repo.update(last_indexed: (@now - 300.seconds).to_datetime)
      indexed_time = @repo.last_indexed

      task = ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent,
        id: @repo.id, force_index: true)

      @repo.reload
      refute_equal indexed_time.inspect, @repo.last_indexed.inspect
      assert_nil task.output[:index_skipped]
    end

    def test_index_performed_if_last_contents_changed_newer_than_last_indexed
      @repo.update(last_indexed: @now - 900.seconds)
      indexed_time = @repo.last_indexed

      task = ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, id: @repo.id)

      @repo.reload
      refute_equal indexed_time.inspect, @repo.last_indexed.inspect
      assert_nil task.output[:index_skipped]
    end
  end
end
