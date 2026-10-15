require 'katello_test_helper'
require 'katello/upload_staging_migration'

module Katello
  class UploadStagingMigrationTest < ActiveSupport::TestCase
    setup do
      skip 'Foreman Active Storage support is required' unless UploadStaging.supported?
      @repository = katello_repositories(:pulp3_file_1)
      @plan_uuid = SecureRandom.uuid
      @directory = Dir.mktmpdir('katello-legacy-upload-test')
      UploadStaging.stubs(:legacy_root).returns(@directory)
      @path = File.join(@directory, 'content.txt')
      File.binwrite(@path, 'legacy content')
      input = {
        repository: { id: @repository.id },
        tmp_files: [{ path: @path, filename: 'content.txt' }],
      }
      @task = stub(id: 42, external_id: @plan_uuid, execution_plan_action: stub(input: input))
      @tasks = stub
      @tasks.stubs(:where).returns(@tasks)
      @tasks.stubs(:not).returns(@tasks)
      @tasks.stubs(:find_each).yields(@task)
      @tasks.stubs(:exists?).returns(false)
      ForemanTasks::Task.stubs(:where).with(label: UploadStagingMigration::LABEL).returns(@tasks)
      @owner = stub(result: 'success')
      ForemanTasks::Task.stubs(:where).with(external_id: @plan_uuid, state: 'stopped').returns(stub(first: @owner))
      @output = StringIO.new
    end

    teardown do
      FileUtils.remove_entry(@directory) if @directory && File.directory?(@directory)
    end

    def migrate(**attributes)
      UploadStagingMigration.new(output: @output, **attributes).run
    end

    test 'preview leaves files, task inputs and storage unchanged' do
      UploadStaging.expects(:store!).never
      assert_equal 1, migrate[:eligible]
      assert_equal @path, @task.execution_plan_action.input[:tmp_files].first[:path]
      assert_equal 'legacy content', File.binread(@path)
    end

    test 'imports a resumable task without rewriting serialized input and is repeatable' do
      assert_equal 1, migrate(apply: true)[:copied]
      record = UploadStaging.find_by!(legacy_path: @path)
      assert_equal @plan_uuid, record.execution_plan_uuid
      assert_equal @repository.id, record.repository_id
      assert_equal 'legacy content', record.file.download
      assert_equal 1, migrate(apply: true)[:skipped]
      assert File.exist?(@path)
    end

    test 'cleanup is explicit and rechecks bytes before deleting both temporary copies' do
      migrate(apply: true)
      assert_equal 1, migrate(cleanup: true)[:eligible]
      assert File.exist?(@path)
      assert_raises(RuntimeError) { migrate(apply: true, cleanup: true) }
      assert_equal 1, migrate(apply: true, cleanup: true, drained: true)[:cleaned]
      refute File.exist?(@path)
      refute UploadStaging.exists?(legacy_path: @path)
    end

    test 'active or paused uploads block destructive cleanup' do
      migrate(apply: true)
      @tasks.stubs(:exists?).returns(true)
      assert_raises(RuntimeError) { migrate(apply: true, cleanup: true, drained: true) }
      assert File.exist?(@path)
    end

    test 'stopped failed and cancelled owners release their copy but retain the original' do
      ['error', 'cancelled'].each do |result|
        migrate(apply: true)
        record = UploadStaging.find_by!(legacy_path: @path)
        blob = record.file.blob
        @owner.stubs(:result).returns(result)

        assert_equal 1, migrate(cleanup: true)[:eligible]
        assert UploadStaging.exists?(record.id)
        assert_equal 1, migrate(apply: true, cleanup: true, drained: true)[:cleaned]
        refute UploadStaging.exists?(record.id)
        refute blob.service.exist?(blob.key)
        assert_equal 'legacy content', File.binread(@path)
      end
    end

    test 'missing or nonterminal owners retain the staging attachment' do
      migrate(apply: true)
      record = UploadStaging.find_by!(legacy_path: @path)
      ForemanTasks::Task.stubs(:where).with(external_id: @plan_uuid, state: 'stopped').returns(stub(first: nil))

      assert_equal 1, migrate(apply: true, cleanup: true, drained: true)[:skipped]
      assert record.reload.file.attached?
      assert File.exist?(@path)
    end

    test 'changed or corrupt copies retain the source' do
      migrate(apply: true)
      record = UploadStaging.find_by!(legacy_path: @path)
      record.file.blob.service.upload(record.file.blob.key, StringIO.new('corrupt'))
      assert_equal 1, migrate(apply: true, cleanup: true, drained: true)[:failed]
      assert_equal 'legacy content', File.binread(@path)
    end

    test 'symlinks and ambiguous task ownership are refused' do
      File.unlink(@path)
      File.symlink('/does-not-exist', @path)
      assert_equal 1, migrate(apply: true)[:failed]
      File.unlink(@path)
      File.binwrite(@path, 'legacy content')
      @tasks.stubs(:find_each).multiple_yields(@task, @task)
      assert_equal 2, migrate(apply: true)[:failed]
      refute UploadStaging.exists?(legacy_path: @path)
    end

    test 'unowned files are neither imported nor recursively removed' do
      unrelated = File.join(@directory, 'unknown.bin')
      File.binwrite(unrelated, 'unknown')
      migrate(apply: true)
      migrate(apply: true, cleanup: true, drained: true)
      assert_equal 'unknown', File.binread(unrelated)
    end
  end
end
