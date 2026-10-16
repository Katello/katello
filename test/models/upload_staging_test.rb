require 'katello_test_helper'

module Katello
  class UploadStagingTest < ActiveSupport::TestCase
    setup do
      skip 'Foreman Active Storage support is required' unless UploadStaging.supported?
      @repository = katello_repositories(:pulp3_file_1)
      @plan_uuid = SecureRandom.uuid
      @directory = Dir.mktmpdir('katello-staging-test')
      @path = File.join(@directory, 'content.txt')
      File.binwrite(@path, 'repository content')
    end

    teardown do
      FileUtils.remove_entry(@directory) if @directory && File.directory?(@directory)
    end

    def store(**attributes)
      UploadStaging.store!(@path, repository: @repository, execution_plan_uuid: @plan_uuid, **attributes)
    end

    test 'stores and verifies bytes and passes an owned reference instead of a path' do
      record = store
      assert_equal Digest::SHA256.file(@path).hexdigest, record.sha256
      record.open { |file| assert_equal 'repository content', file.read }
      assert_equal record.id, record.metadata[:staging_id]
      refute record.metadata.key?(:path)
      assert_equal record, UploadStaging.resolve(record.metadata, @repository.id, @plan_uuid)
    end

    test 'another repository or execution plan cannot resolve the staging ID' do
      record = store
      assert_raises(ActiveRecord::RecordNotFound) { UploadStaging.resolve(record.metadata, -1, @plan_uuid) }
      assert_raises(ActiveRecord::RecordNotFound) { UploadStaging.resolve(record.metadata, @repository.id, SecureRandom.uuid) }
    end

    test 'legacy inputs can resolve an imported copy even if its local source is absent' do
      record = store(legacy_path: @path)
      File.unlink(@path)
      assert_equal record, UploadStaging.resolve(@path, @repository.id, @plan_uuid)
      record.open { |file| assert_equal 'repository content', file.read }
    end

    test 'corrupt storage is rejected before forwarding data to Pulp' do
      record = store
      blob = record.file.blob
      blob.service.upload(blob.key, StringIO.new('corrupt'))
      assert_raises(ActiveStorage::IntegrityError) { record.open { flunk 'corrupt bytes were yielded' } }
    end

    test 'upload failure leaves no new staging row or blob' do
      rows = UploadStaging.count
      blobs = ActiveStorage::Blob.count
      ActiveStorage::Blob.service.expects(:upload).raises(IOError)
      assert_raises(IOError) { store }
      assert_equal rows, UploadStaging.count
      assert_equal blobs, ActiveStorage::Blob.count
      assert File.exist?(@path)
    end

    test 'purge deletes only the owned temporary copy' do
      record = store
      other = store
      blob = record.file.blob
      record.purge!
      refute UploadStaging.exists?(record.id)
      refute blob.service.exist?(blob.key)
      assert_equal 'repository content', other.file.download
      assert File.exist?(@path)
    end
  end
end
