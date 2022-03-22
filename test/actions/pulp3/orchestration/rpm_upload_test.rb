require 'katello_test_helper'

module ::Actions::Pulp3
  class RpmUploadTest < ActiveSupport::TestCase
    include Katello::Pulp3Support

    def setup
      @primary = SmartProxy.pulp_primary
      @repo = katello_repositories(:fedora_17_x86_64)
      file1 = File.join(Katello::Engine.root, 'test/fixtures/test_repos/zoo/duck-0.7-1.noarch.rpm')
      file2 = File.join(Katello::Engine.root, 'test/fixtures/test_repos/zoo/kangaroo-0.2-1.noarch.rpm')
      @file1 = {path: file1, filename: 'duck-0.7.1.noarch.rpm'}
      @file2 = {path: file2, filename: 'kangaroo-0.2-1.noarch.rpm'}
      create_repo(@repo, @primary)
    end

    def teardown
      ForemanTasks.sync_task(
          ::Actions::Pulp3::Orchestration::Repository::Delete, @repo, @primary)
      ForemanTasks.sync_task(
          ::Actions::Pulp3::Orchestration::OrphanCleanup::RemoveOrphans, @primary)
    end

    def test_upload
      @repo.reload
      assert @repo.remote_href

      VCR.use_cassette(cassette_name + '_binary', :match_requests_on => [:method, :path, :params]) do
        action_result = ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::UploadContent, @repo, @primary, @file1, 'rpm')
        assert_equal "success", action_result.result
        @repo.reload
        repository_reference = Katello::Pulp3::RepositoryReference.find_by(
            :root_repository_id => @repo.root.id,
            :content_view_id => @repo.content_view.id)
        assert_equal repository_reference.repository_href + "versions/1/", @repo.version_href

        action_result = ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::UploadContent, @repo, @primary, @file2, 'rpm')
        assert_equal "success", action_result.result
        @repo.reload
        repository_reference = Katello::Pulp3::RepositoryReference.find_by(
          :root_repository_id => @repo.root.id,
          :content_view_id => @repo.content_view.id)
        assert_equal repository_reference.repository_href + "versions/2/", @repo.version_href
      end
    end

    def test_duplicate_upload
      action_result = ""
      @repo.reload
      assert @repo.remote_href

      VCR.use_cassette(cassette_name + '_binary', :match_requests_on => [:method, :path, :params]) do
        action_result = ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::UploadContent, @repo, @primary, @file1, 'rpm')
      end
      assert_equal "success", action_result.result
      @repo.reload
      repository_reference = Katello::Pulp3::RepositoryReference.find_by(
          :root_repository_id => @repo.root.id,
          :content_view_id => @repo.content_view.id)
      assert_equal repository_reference.repository_href + "versions/1/", @repo.version_href

      VCR.use_cassette(cassette_name + '_binary_duplicate', :match_requests_on => [:method, :path, :params]) do
        action_result = ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::UploadContent, @repo, @primary, @file1, 'rpm')
      end
      assert_equal "success", action_result.result
      @repo.reload
      repository_reference = Katello::Pulp3::RepositoryReference.find_by(
          :root_repository_id => @repo.root.id,
          :content_view_id => @repo.content_view.id)
      assert_equal repository_reference.repository_href + "versions/1/", @repo.version_href
    end
  end
end
