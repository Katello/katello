require 'katello_test_helper'

module ::Actions::Pulp3
  class SrpmUploadTest < ActiveSupport::TestCase
    include Katello::Pulp3Support

    def setup
      @primary = SmartProxy.pulp_primary
      @repo = katello_repositories(:fedora_17_x86_64)
      tmp_file = File.join(Katello::Engine.root, 'test/fixtures/files/test-srpm01-1.0-1.src.rpm')
      @file = {path: tmp_file, filename: 'test-srpm01-1.0-1.src.rpm'}
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

      VCR.use_cassette(cassette_name + '_binary', :match_requests_on => [:method, :path, :params]) do
        action_result = ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::UploadContent, @repo, @primary, @file, 'srpm')
      end
      assert_equal "success", action_result.result
      @repo.reload
      repository_reference = Katello::Pulp3::RepositoryReference.find_by(
          :root_repository_id => @repo.root.id,
          :content_view_id => @repo.content_view.id)
      assert_equal repository_reference.repository_href + "versions/1/", @repo.version_href
      assert_equal [], @repo.srpms
    end
  end
end
