require 'katello_test_helper'

module ::Actions::Pulp3
  class DebCreateTest < ActiveSupport::TestCase
    include Katello::Pulp3Support

    def setup
      @primary = SmartProxy.pulp_primary
      @repo = katello_repositories(:debian_9_amd64)
      ensure_creatable(@repo, @primary)
    end

    def teardown
      @repo.backend_service(@primary).delete_distributions
      ForemanTasks.sync_task(
        ::Actions::Pulp3::Orchestration::Repository::Delete, @repo, @primary)
    end

    def test_create
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Create, @repo, @primary)
      @repo.reload

      assert @repo.remote_href
      assert @repo.version_href

      repo_reference = Katello::Pulp3::RepositoryReference.find_by(:root_repository_id => @repo.root.id,
                                                                   :content_view_id => @repo.content_view.id)
      assert repo_reference
      assert repo_reference.repository_href
      assert_not_nil repo_reference.repository_prn
      assert_match(/^prn:deb\.aptrepository:[0-9a-f\-]+$/, repo_reference.repository_prn)
    end
  end
end
