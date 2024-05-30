require 'katello_test_helper'
require 'support/pulp3_support'
require "pulpcore_client"

module Katello
  module Service
    module Pulp3
      class ContentTest < ActiveSupport::TestCase
        include Katello::Pulp3Support

        def setup
          @primary = SmartProxy.pulp_primary
          @repo = katello_repositories(:generic_file)
          @repo.root.update(:url => 'http://test/test/')
          tmp_file1 = File.join(Katello::Engine.root, "test/fixtures/files/test_other_type.json")
          @file1 = {path: tmp_file1, filename: "test_other_type.json"}
          tmp_file = File.join(Katello::Engine.root, "test/fixtures/files/test_erratum.json")
          @file = {path: tmp_file, filename: "test_erratum.json"}

          create_repo(@repo, @primary)
        end

        def teardown
          ForemanTasks.sync_task(
              ::Actions::Pulp3::Orchestration::Repository::Delete, @repo, @primary) rescue "skipped repo delete"

          Setting[:orphan_protection_time] = 0
          Setting[:completed_pulp_task_protection_days] = 0
          DateTime.expects(:now).returns(DateTime.new(3000, 1, 1))
          ForemanTasks.sync_task(
              ::Actions::Pulp3::Orchestration::OrphanCleanup::RemoveOrphans, @primary) rescue "skipped remove orphans"
        end

        def test_create_upload
          @repo.reload
          size = File.size(@file1[:path])
          sha256 = Digest::SHA256.hexdigest(File.read(@file1[:path]))
          unit_type_id = "file"
          upload_hash = @repo.backend_content_service(@primary).create_upload(size, sha256, unit_type_id)
          upload_id = upload_hash.with_indifferent_access[:upload_id]

          refute_nil upload_id
        end

        def test_chunk_upload
          chunk_size = 100
          @repo.reload
          size = File.size(@file[:path])
          sha256 = Digest::SHA256.hexdigest(File.read(@file[:path]))
          unit_type_id = "file"
          upload_hash = @repo.backend_content_service(@primary).create_upload(size, sha256, unit_type_id)
          upload_href = upload_hash.with_indifferent_access[:upload_id]

          refute_nil upload_hash.with_indifferent_access[:upload_id], "You likely need to set 'ORPHAN_PROTECTION_TIME = 0' in pulp's settings.py"

          offset = 0
          VCR.use_cassette(cassette_name + '_binary', :match_requests_on => [:method, :path, :params]) do
            File.open(@file[:path], "rb") do |file|
              while (content = file.read(chunk_size))
                @repo.backend_content_service(@primary)
                    .upload_chunk(upload_href, offset, content, size)
                offset += chunk_size
              end
            end

            uploads = [{'id' => upload_href, 'size' => size, 'checksum' => sha256, 'name' => @file[:filename]}]
            task = ::ForemanTasks.sync_task(Actions::Katello::Repository::ImportUpload, @repo, uploads)
            task
          end
          @repo.reload
          @repo.index_content
          assert @repo.file_units.any?
        end
      end
    end
  end
end
