require 'katello_test_helper'

module ::Actions::Pulp3
  class FileUploadTest < ActiveSupport::TestCase
    include Katello::Pulp3Support

    def setup
      @primary = SmartProxy.pulp_primary
      @repo = katello_repositories(:generic_file)
      @repo.root.update(:url => 'http://test/test/')
      tmp_file = File.join(Katello::Engine.root, "test/fixtures/files/test_erratum.json")
      @file = {path: tmp_file, filename: "test_erratum.json"}
      @file1 = {path: tmp_file, filename: "test_erratum1.json"}
      create_repo(@repo, @primary)
    end

    def teardown
      @repo.backend_service(@primary).delete_distributions
      @repo.backend_service(@primary).delete_publication
      ForemanTasks.sync_task(
          ::Actions::Pulp3::Orchestration::Repository::Delete, @repo, @primary)
      ForemanTasks.sync_task(
          ::Actions::Pulp3::Orchestration::OrphanCleanup::RemoveOrphans, @primary)
    end

    def test_upload
      action_result = ""
      @repo.reload
      assert @repo.remote_href
      assert @repo.version_href
      VCR.use_cassette(cassette_name + '_binary', :match_requests_on => [:method, :path, :params]) do
        action_result = ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::UploadContent, @repo, @primary, @file, "file")
      end
      assert_equal "success", action_result.result
      @repo.reload
      repository_reference = Katello::Pulp3::RepositoryReference.find_by(
          :root_repository_id => @repo.root.id,
          :content_view_id => @repo.content_view.id)
      assert_equal repository_reference.repository_href + "versions/1/", @repo.version_href
    end

    def test_duplicate_upload
      action_result = ""
      @repo.reload
      assert @repo.remote_href
      assert @repo.version_href
      VCR.use_cassette(cassette_name + '_binary', :match_requests_on => [:method, :path, :params]) do
        action_result = ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::UploadContent, @repo, @primary, @file, "file")
      end
      assert_equal "success", action_result.result
      @repo.reload
      repository_reference = Katello::Pulp3::RepositoryReference.find_by(
          :root_repository_id => @repo.root.id,
          :content_view_id => @repo.content_view.id)
      assert_equal repository_reference.repository_href + "versions/1/", @repo.version_href

      VCR.use_cassette(cassette_name + '_binary_duplicate', :match_requests_on => [:method, :path, :params]) do
        action_result = ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::UploadContent, @repo, @primary, @file1, "file")
      end
      assert_equal "success", action_result.result
      @repo.reload
      repository_reference = Katello::Pulp3::RepositoryReference.find_by(
          :root_repository_id => @repo.root.id,
          :content_view_id => @repo.content_view.id)
      repo_backend_service = @repo.backend_service(@primary)
      version_details = repo_backend_service.lookup_version @repo.version_href
      assert_equal repository_reference.repository_href + "versions/2/", @repo.version_href
      assert_equal 2, version_details.content_summary.present["file.file"].count
    end
  end
end
