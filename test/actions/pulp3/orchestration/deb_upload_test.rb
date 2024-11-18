require 'katello_test_helper'

module ::Actions::Pulp3
  class DebUploadTest < ActiveSupport::TestCase
    include Katello::Pulp3Support

    def setup
      @primary = SmartProxy.pulp_primary
      @repo = katello_repositories(:debian_10_amd64)
      @content = katello_contents(:deb_content)
      @repo.content_id = @content.cp_content_id
      file1 = File.join(Katello::Engine.root, 'test/fixtures/files/frigg_1.0_ppc64.deb')
      file2 = File.join(Katello::Engine.root, 'test/fixtures/files/odin_1.0_ppc64.deb')
      @file1 = {path: file1, filename: 'frigg_1.0_ppc64.deb'}
      @file2 = {path: file2, filename: 'odin_1.0_ppc64.deb'}
      create_repo(@repo, @primary)
      ::Katello::Resources::Candlepin::Content.stubs(:update)
      @content.stubs(:update!)
    end

    def teardown
      @repo.backend_service(@primary).delete_distributions
      @repo.backend_service(@primary).delete_publication
      ForemanTasks.sync_task(
          ::Actions::Pulp3::Orchestration::Repository::Delete, @repo, @primary)
    end

    def test_upload
      @repo.reload
      assert @repo.remote_href
      deb_count = @repo.debs.count

      VCR.use_cassette(cassette_name + '_binary', :match_requests_on => [:method, :path, :params]) do
        action_result = ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::UploadContent, @repo, @primary, @file1, 'deb')
        assert_equal "success", action_result.result
        @repo.reload
        repository_reference = Katello::Pulp3::RepositoryReference.find_by(
            :root_repository_id => @repo.root.id,
            :content_view_id => @repo.content_view.id)
        assert_equal repository_reference.repository_href + "versions/2/", @repo.version_href

        upload_action = ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::UploadContent, @repo, @primary, @file2, 'deb')
        assert_equal "success", upload_action.result
        finish_upload_action = ForemanTasks.sync_task(::Actions::Katello::Repository::FinishUpload, @repo, content_type: 'deb', upload_actions: [upload_action.output])
        assert_equal "success", finish_upload_action.result
        @repo.reload
        repository_reference = Katello::Pulp3::RepositoryReference.find_by(
          :root_repository_id => @repo.root.id,
          :content_view_id => @repo.content_view.id)
        assert_equal repository_reference.repository_href + "versions/3/", @repo.version_href
        assert_equal @repo.debs.count, deb_count + 1
      end
    end

    def test_duplicate_upload
      action_result = ""
      @repo.reload
      assert @repo.remote_href

      VCR.use_cassette(cassette_name + '_binary', :match_requests_on => [:method, :path, :params]) do
        action_result = ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::UploadContent, @repo, @primary, @file1, 'deb')
      end
      assert_equal "success", action_result.result
      @repo.reload
      repository_reference = Katello::Pulp3::RepositoryReference.find_by(
          :root_repository_id => @repo.root.id,
          :content_view_id => @repo.content_view.id)
      assert_equal repository_reference.repository_href + "versions/2/", @repo.version_href

      VCR.use_cassette(cassette_name + '_binary_duplicate', :match_requests_on => [:method, :path, :params]) do
        action_result = ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::UploadContent, @repo, @primary, @file1, 'deb')
      end
      assert_equal "success", action_result.result
      @repo.reload
      repository_reference = Katello::Pulp3::RepositoryReference.find_by(
          :root_repository_id => @repo.root.id,
          :content_view_id => @repo.content_view.id)
      assert_equal repository_reference.repository_href + "versions/2/", @repo.version_href
    end
  end
end
