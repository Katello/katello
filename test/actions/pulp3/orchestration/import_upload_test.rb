require 'katello_test_helper'

module ::Actions::Pulp3
  class ImportUploadTest < ActiveSupport::TestCase
    include Katello::Pulp3Support

    def setup
      @primary = SmartProxy.pulp_primary
      @repo1 = katello_repositories(:debian_10_amd64)
      create_repo(@repo1, @primary)
      @repo2 = katello_repositories(:fedora_17_x86_64)
      create_repo(@repo2, @primary)
      @repo3 = katello_repositories(:generic_file)
      create_repo(@repo3, @primary)
    end

    def upload_file(content_unit_type, filename, repo)
      path = File.join(Katello::Engine.root, 'test/fixtures/files/', filename)
      content = File.read(path)
      file = {path: path, filename: filename, checksum: Digest::SHA256.hexdigest(content)}

      file.merge! repo.backend_content_service(@primary).create_upload(
        content.bytesize,
        file[:checksum],
        content_unit_type,
        repo
      )
      file[:upload_href] = repo.backend_content_service(@primary)
        .upload_chunk(
          file['upload_id'], 0, content, content.bytesize
        ).pulp_href

      file
    end

    def teardown
      [@repo1, @repo2, @repo3].each do |repo|
        repo.backend_service(@primary).delete_distributions
        repo.backend_service(@primary).delete_publication
        ForemanTasks.sync_task(
          ::Actions::Pulp3::Orchestration::Repository::Delete, repo, @primary)
      end
      # cleanup orphaned content
      ::Katello::Pulp3::Api::Core.new(@primary).orphans_api.cleanup(
        ::PulpcoreClient::OrphansCleanup.new(orphan_protection_time: 0)
      )
    end

    def run_upload_test(content_unit_type, filename, repo, content_path_match)
      VCR.use_cassette(cassette_name + '_binary', :match_requests_on => [:method, :path, :params]) do
        file = upload_file(content_unit_type, filename, repo)

        action_result = ForemanTasks.sync_task(
          ::Actions::Pulp3::Orchestration::Repository::ImportUpload, repo, @primary,
          {
            unit_type_id: content_unit_type,
            upload_id: file['upload_id'],
            unit_key: {
              name: file[:filename],
              checksum: file[:checksum],
            },
          }
        )

        assert_equal 'success', action_result.result
        assert_match content_path_match, action_result.output[:content_unit_href]
      end
    end

    def test_deb_upload
      run_upload_test('deb', 'frigg_1.0_ppc64.deb', @repo1, %r{^/pulp/api/v3/content/deb/packages/})
    end

    def test_file_upload
      run_upload_test('file', 'frigg_1.0_ppc64.deb', @repo3, %r{^/pulp/api/v3/content/file/files/})
    end

    def test_rpm_upload
      run_upload_test('rpm', 'squirrel-0.3-0.8.noarch.rpm', @repo2, %r{^/pulp/api/v3/content/rpm/packages/})
    end
  end
end
